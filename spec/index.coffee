
require "./https-mock"
https = require "https"

serv = require ".."

describe "serv.set", ->
  url = "https://x.com/api/"
  x = null

  it "creates a service", ->
    x = serv.set "x", {url}
    expect(x.constructor.name).toBe "Service"
    expect(x.url).toBe url

  it "adds the service to a registry", ->
    expect(x).toBe serv("x")

describe "Service", ->

  describe ".get()", ->

    it "sends a GET request", ->
      serv("x").get "y"
      .then (res) ->
        {req} = https
        expect(res.success).toBe true
        expect(req.headers).toEqual
          "Accept": "*/*"
        expect(req).toEqual
          method: undefined
          headers: req.headers
          host: "x.com"
          path: "/api/y"
          ca: undefined
          rejectUnauthorized: false

    it "supports custom headers", ->
      serv("x").get "", {a: 1, b: 2, headers: {"User-Agent": "serv-test"}}
      .then ->
        {req} = https
        expect(req.path).toBe "/api/?a=1&b=2"
        expect(req.headers).toEqual
          "Accept": "*/*"
          "User-Agent": "serv-test"

  describe ".post()", ->

    it "sends a POST request", ->
      json = {a: 1, b: 2}
      serv("x").post "z", json
      .then (res) ->
        {req} = https
        data = JSON.stringify json
        expect(res.success).toBe true
        expect(req.headers).toEqual
          "Accept": "*/*"
          "Content-Type": "application/json"
          "Content-Length": Buffer.byteLength data
        expect(req).toEqual
          method: "POST"
          headers: req.headers
          host: "x.com"
          path: "/api/z"
          ca: undefined
          rejectUnauthorized: false
          data: data

    it "supports custom headers", ->
      serv("x").post "", {a: 1, b: 2, headers: {"User-Agent": "serv-test"}}
      .then ->
        {req} = https
        data = JSON.stringify {a: 1, b: 2}
        expect(req.data).toBe data
        expect(req.headers).toEqual
          "Accept": "*/*"
          "Content-Type": "application/json"
          "Content-Length": Buffer.byteLength data
          "User-Agent": "serv-test"
