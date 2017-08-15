
# serv v1.0.0 ![stable](https://img.shields.io/badge/stability-stable-4EBA0F.svg?style=flat)

Send requests to third-party APIs from your NodeJS server.

```coffee
serv = require "serv"

# Useful configuration (see the `Configuration` section)
api = serv.set "goo.gl",
  url: "https://www.googleapis.com/urlshortener/v1/"
  key: "BIzbSzDWtmEueMiF_qhlvZLU6NW0Rpc6DQPSlsk"

# HTTP methods with custom `Response` objects
api.post "url", {longUrl: "https://github.com/aleclarson/serv"}

# Define GET queries with an object
api.get "url", {shortUrl: "http://goo.gl/fbsS"}

# Extend the service for easier usage
api.shorten = (longUrl) ->
  @post "url", {longUrl}

# Access a service from elsewhere using its ID
serv("goo.gl").shorten "https://github.com/aleclarson/serv"
```

### Configuration

- `url` The base URL used with each request
- `key` The API key added to the query of each request
- `auth` The `Authorization` header of each request (can be a string or a function)
- `certAuth` An authority certificate to check the remote host against (can be a string or array)
- `rate` The time window (in seconds) wherein the call rate is limited
- `rateLimit` The number of calls before the limit is exceeded
- `dataType` The encoding used with POST data

#### Notes

- Valid values for `dataType` are "json", "form", "binary", or "text".
- Set `dataType` to "form" to stringify the POST data for `x-www-form-urlencoded` requests.
- Override `dataType` for a single request by defining `headers["Content-Type"]` manually.
- When `auth` is a string, it's encoded with base64 and appended to `"Basic "`.
- When `auth` is a function, its return value is used as-is. This is useful for non-basic authorization.
- When calling `post`, the POST data can be an object, buffer, or string.
- Both GET queries and POST data support a special `headers` key for custom request headers.
- The `post` method also supports passing a headers object as the third argument.
