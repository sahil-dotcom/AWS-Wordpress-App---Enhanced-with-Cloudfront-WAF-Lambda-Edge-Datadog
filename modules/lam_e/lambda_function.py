import json

def lambda_handler(event, context):
    response = event["Records"][0]["cf"]["response"]
    headers = response["headers"]

    # Security headers
    headers["strict-transport-security"] = [{"key": "Strict-Transport-Security", "value": "max-age=63072000; includeSubDomains; preload"}]
    headers["x-content-type-options"] = [{"key": "X-Content-Type-Options", "value": "nosniff"}]
    headers["x-frame-options"] = [{"key": "X-Frame-Options", "value": "DENY"}]
    headers["content-security-policy"] = [{"key": "Content-Security-Policy", "value": "default-src 'self'; script-src 'self';"}]
    headers["referrer-policy"] = [{"key": "Referrer-Policy", "value": "strict-origin-when-cross-origin"}]
    headers["permissions-policy"] = [{"key": "Permissions-Policy", "value": "geolocation=(), microphone=(), camera=()"}]

    # CORS headers
    headers["access-control-allow-origin"] = [{"key": "Access-Control-Allow-Origin", "value": "*"}]
    headers["access-control-allow-methods"] = [{"key": "Access-Control-Allow-Methods", "value": "GET, OPTIONS"}]
    headers["access-control-allow-headers"] = [{"key": "Access-Control-Allow-Headers", "value": "Content-Type"}]
    headers["access-control-allow-credentials"] = [{"key": "Access-Control-Allow-Credentials", "value": "true"}]

    return response