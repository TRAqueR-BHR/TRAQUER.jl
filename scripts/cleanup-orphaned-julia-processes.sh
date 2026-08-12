#!/usr/bin/env bash
set -euo pipefail

# Cleanup helper for TRAQUER development containers.
#
# What it does:
#   - Finds orphaned Julia processes whose parent is PID 1.
#   - By default, only targets Julia distributed worker processes (`julia ... --worker`).
#   - Sends SIGTERM, waits a little, then sends SIGKILL to survivors.
#   - Reports zombie/defunct Julia processes.
#
# Important: a zombie process is already dead. It cannot be killed directly.
# Only its parent can reap it by calling wait(). If the zombie parent is PID 1 and
# PID 1 is not a real init process, the practical fix is to restart the container
# or run the container with Docker Compose `init: true`.

usage() {
  cat <<'EOF'
Usage: scripts/cleanup-orphaned-julia-processes.sh [options]

Options:
  --dry-run              Show what would be killed, but do not send signals.
  --all-orphaned-julia   Kill every orphaned Julia process with PPID=1.
                         Default: only kill orphaned Julia workers containing --worker.
  --kill-zombie-parents  For Julia zombies whose parent is not PID 1, kill the parent
                         process after trying SIGCHLD. Use with care.
  -h, --help             Show this help.

Examples:
  scripts/cleanup-orphaned-julia-processes.sh --dry-run
  scripts/cleanup-orphaned-julia-processes.sh
  scripts/cleanup-orphaned-julia-processes.sh --all-orphaned-julia
EOF
}

DRY_RUN=false
ALL_ORPHANED_JULIA=false
KILL_ZOMBIE_PARENTS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      ;;
    --all-orphaned-julia)
      ALL_ORPHANED_JULIA=true
      ;;
    --kill-zombie-parents)
      KILL_ZOMBIE_PARENTS=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

is_julia_cmd() {
  local cmd="$1"
  [[ "$cmd" == *julia* ]]
}

is_worker_cmd() {
  local cmd="$1"
  [[ "$cmd" == *--worker* ]]
}

print_process_table() {
  local title="$1"
  shift
  local pids=("$@")

  echo
  echo "== ${title} =="
  if [[ ${#pids[@]} -eq 0 ]]; then
    echo "None."
    return
  fi

  ps -o pid,ppid,stat,pcpu,pmem,rss,etime,args -p "$(IFS=,; echo "${pids[*]}")" || true
}

mapfile -t ORPHANED_JULIA_PIDS < <(
  ps -eo pid=,ppid=,stat=,args= |
    while read -r pid ppid stat args; do
      [[ "$ppid" == "1" ]] || continue
      [[ "$stat" != Z* ]] || continue
      is_julia_cmd "$args" || continue

      if [[ "$ALL_ORPHANED_JULIA" == true ]] || is_worker_cmd "$args"; then
        echo "$pid"
      fi
    done
)

mapfile -t JULIA_ZOMBIE_ROWS < <(
  ps -eo pid=,ppid=,stat=,args= |
    while read -r pid ppid stat args; do
      [[ "$stat" == Z* ]] || continue
      is_julia_cmd "$args" || [[ "$args" == *'[julia] <defunct>'* ]] || continue
      echo "$pid $ppid"
    done
)

print_process_table "Orphaned Julia processes targeted for cleanup" "${ORPHANED_JULIA_PIDS[@]}"

echo
echo "== Julia zombie processes =="
if [[ ${#JULIA_ZOMBIE_ROWS[@]} -eq 0 ]]; then
  echo "None."
else
  printf '%s\n' "${JULIA_ZOMBIE_ROWS[@]}" | while read -r pid ppid; do
    ps -o pid,ppid,stat,pcpu,pmem,rss,etime,args -p "$pid" || true
    echo "  Note: zombie PID $pid cannot be killed directly; parent PID $ppid must reap it."
  done
fi

if [[ "$DRY_RUN" == true ]]; then
  echo
  echo "Dry run enabled; no signals sent."
  exit 0
fi

if [[ ${#ORPHANED_JULIA_PIDS[@]} -gt 0 ]]; then
  echo
  echo "Sending SIGTERM to orphaned Julia process(es): ${ORPHANED_JULIA_PIDS[*]}"
  kill -TERM "${ORPHANED_JULIA_PIDS[@]}" 2>/dev/null || true

  sleep 5

  mapfile -t SURVIVORS < <(
    for pid in "${ORPHANED_JULIA_PIDS[@]}"; do
      if kill -0 "$pid" 2>/dev/null; then
        echo "$pid"
      fi
    done
  )

  if [[ ${#SURVIVORS[@]} -gt 0 ]]; then
    echo "Sending SIGKILL to remaining orphaned Julia process(es): ${SURVIVORS[*]}"
    kill -KILL "${SURVIVORS[@]}" 2>/dev/null || true
  fi
else
  echo
  echo "No orphaned Julia process matched the cleanup criteria."
fi

if [[ ${#JULIA_ZOMBIE_ROWS[@]} -gt 0 ]]; then
  echo
  echo "Trying to wake zombie parent process(es) with SIGCHLD."
  mapfile -t ZOMBIE_PARENT_PIDS < <(printf '%s\n' "${JULIA_ZOMBIE_ROWS[@]}" | awk '{print $2}' | sort -n | uniq)

  for ppid in "${ZOMBIE_PARENT_PIDS[@]}"; do
    if [[ "$ppid" == "1" ]]; then
      echo "Zombie parent is PID 1; cannot safely kill it. Restart the container or use Compose init: true."
      continue
    fi

    echo "Sending SIGCHLD to parent PID $ppid"
    kill -CHLD "$ppid" 2>/dev/null || true

    if [[ "$KILL_ZOMBIE_PARENTS" == true ]]; then
      echo "--kill-zombie-parents enabled; sending SIGTERM to parent PID $ppid"
      kill -TERM "$ppid" 2>/dev/null || true
    fi
  done
fi

echo
 echo "Cleanup complete. Current Julia processes:"
ps -eo pid,ppid,stat,pcpu,pmem,rss,etime,args | grep -E '[j]ulia|\[julia\] <defunct>' || true
