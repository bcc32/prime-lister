app = angular.module 'PrimesApp', []

rowLength = 20

app.controller 'PrimesController', ['$scope', '$http', ($scope, $http) ->
  $scope.primeTable = []
  $scope.rowLength = rowLength

  $http.get('/primes', cache: true).then ((res) ->
    $scope.primeTable.push [] for _ in [0..(res.data.length - 1) / rowLength]
    $scope.primeTable[i // rowLength].push res.data[i] \
      for i in [0...res.data.length]
    return
  ), (res) ->
    $scope.primeTable = []
    return
]
