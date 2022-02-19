using HTTP
using HTTP.URIs: URI

# Overwrite Mux.todict because we need the request Content-Type to be able to
#  handle multipart form data (for file upload)
function Mux.todict(req::HTTP.Request)
  req′ = Dict()
  req′[:method]   = req.method
  req′[:headers]  = req.headers
  req′[:resource] = req.target
  req′[:data] = req.body
  req′[:uri] = URI(req.target)
  req′[:cookies]  = HTTP.Cookies.cookies(req)
  req′[:ContentType] = req["Content-Type"] # This does not exist in Mux
  return req′
end
