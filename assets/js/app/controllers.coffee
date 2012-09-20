
controllers = angular.module "collection-browser.controllers", []

AppController = [
  "request"
  "$location"
  "$scope"

  (request, $location, $scope)->
    # Default to show the items in the collection
    $scope.showItems = true

    $scope.navigate = (uri)->
      $location.search "uri", uri
      makeRequest()

    $scope.submit = (form)->
      properties = {}
      for property in form
        properties[property.name] = property.value

      request.post($scope.serviceUrl, properties, {}, $scope.useProxy)
        .success((body, status, headers)->
          console.log "Form submitted"
        )
        .error (body, status, headers)->
          $scope.error =
            title: body.title||"Error"
            message: body.message||body
            code: body.code||status

    $scope.query = (href, form)->
      properties = {}
      for property in form
        properties[property.name] = property.value

      uri = href

      # build query params from form

      $location.search "uri", uri

    makeRequest = ()->
      uri = $location.search().uri

      if not uri or uri == "undefined"
        $scope.collection = null
        $scope.template = null
        $scope.error = null
        return

      $scope.serviceUrl = uri
      request.get(uri, {}, $scope.useProxy)
        .success((body, status, headers)->
          $scope.collection = body.collection
          $scope.template = angular.copy body.collection.template
          $scope.error = null
        )
        .error (body, status, headers)->
          $scope.collection = null
          $scope.template = null
          $scope.error =
            title: body.title||"Error"
            message: body.message||body
            code: body.code||status

    $scope.$watch (()-> $location.absUrl()), makeRequest
]

controllers.controller "AppController", AppController
