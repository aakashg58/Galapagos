# (Object _, [(Object _, String)], String, t) -> Object _
window.addProxyTo =
  (proxies, objKeyPairs, proxyKey, value) ->

    apply = (x) -> (f) -> f(x)

    backingValue = value

    # This `map` is side-effecting
    # We return a setter for each variable, yes, but we also rejigger any
    # any existing getter or setter to basically call the old code for any
    # side-effects it produces, and then behave how we want (i.e. as a proxy) --JAB (8/9/16)
    setters =
      objKeyPairs.map(
        ([obj, key]) ->

          { get, set } = Object.getOwnPropertyDescriptor(obj, key) ? {}

          proxyGetter =            -> get?(); backingValue
          proxySetter = (newValue) -> set?(newValue); return

          Object.defineProperty(obj, key, {
            get: proxyGetter
            set: (newValue) -> proxies[proxyKey] = newValue
          })

          proxySetter

      )

    Object.defineProperty(proxies, proxyKey, {
      get: -> backingValue
      set: (newValue) -> backingValue = newValue; setters.forEach(apply(newValue))
    })

    proxies
