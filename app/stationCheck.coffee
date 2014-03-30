module.exports = stationCheck = (array, input) ->
  answer = false
  input = input.toUpperCase()
  for item in array
    do (item) ->
      answer = true if item is input
  return answer
