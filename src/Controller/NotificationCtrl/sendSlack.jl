using HTTP
using JSON

function NotificationCtrl.sendSlack(message::String)::HTTP.Response
    slackWebhookUrl = Conf.getSlackWebhookUrl()
    slackToken = Conf.getSlackToken()
    slackChannel= Conf.getSlackChannel()

    # "https://slack.com/api/chat.postMessage"
    url = slackWebhookUrl
    headers = ["Authorization" => "Bearer $slackToken", "Content-Type" => "application/json"]
    data = JSON.json(Dict("channel" => slackChannel, "text" => message))
    response = HTTP.Response(300, Dict(), "")
    try
        response = HTTP.request("POST", url, headers, data)
    catch e
        @error "Error sending slack message: $e"
        response = HTTP.Response(500, Dict(), "Error sending slack message: $e")
    end
    return response
end
