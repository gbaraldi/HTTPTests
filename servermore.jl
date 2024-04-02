using HTTP
using Dates
using JSON3
using Profile
using ProfileView
struct Message
    message::String
end

router = HTTP.Router()

function plaintext(req::HTTP.Request)
    headers = [
        "Content-Type" => "text/plain",
        "Server" => "Julia-HTTP",
        "Date" => Dates.format(Dates.now(), Dates.RFC1123Format) * " GMT",
    ]

    return HTTP.Response(200, headers, body = "Hello, World!")
end

function jsonSerialization(req::HTTP.Request)
    headers = [
        "Content-Type" => "application/json",
        "Server" => "Julia-HTTP",
        "Date" => Dates.format(Dates.now(), Dates.RFC1123Format) * " GMT",
    ]
    return HTTP.Response(200, headers, body = JSON3.write(Message("Hello, World!")))
end

function notfound(request)
    return HTTP.Response(404, [], "")
end

HTTP.register!(router, "GET", "/plaintext", plaintext)
HTTP.register!(router, "GET", "/json", jsonSerialization)

HTTP.register!(router, "/**", notfound)
HTTP.register!(router, "/", notfound)


t = Threads.@spawn :default HTTP.serve(router, "0.0.0.0" , 8081, reuseaddr=true)
sleep(1)
run(`wrk -t8 -c200 -d5s -H 'Host: example.com' --timeout 2s http://localhost:8081/plaintext`)

run(`wrk -t8 -c200 -d5s -H 'Host: example.com' --timeout 2s http://localhost:8081/plaintext`, wait = false)

@profile sleep(6)

ProfileView.view(C=true)


