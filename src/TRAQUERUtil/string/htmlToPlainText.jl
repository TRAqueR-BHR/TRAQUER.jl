function TRAQUERUtil.htmlToPlainText(html::AbstractString)
    result = html
    # Block-level / line-break tags: convert to whitespace
    result = replace(result, r"<br\s*/?>"i => "\n")
    result = replace(result, r"</p\s*>"i => "\n\n")
    result = replace(result, r"<p\b[^>]*>"i => "")
    # Strip remaining HTML tags
    result = replace(result, r"<[^>]+>" => "")
    # Decode common HTML entities
    result = replace(result, "&nbsp;" => " ")
    result = replace(result, "&amp;" => "&")
    result = replace(result, "&lt;" => "<")
    result = replace(result, "&gt;" => ">")
    result = replace(result, "&quot;" => "\"")
    result = replace(result, "&#39;" => "'")
    return string(strip(result))
end