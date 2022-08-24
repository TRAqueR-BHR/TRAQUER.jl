# Add internal TRAQUER ref
ALTER TABLE public.patient
    ADD COLUMN traquer_ref integer;

# Add schema usersch

# Rename 'instance_name' to 'instance_code_name' in config
