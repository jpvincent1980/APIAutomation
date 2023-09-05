*** Settings ***
Library     RequestsLibrary
Library     Collections
Test Tags   Test  API


*** Variables ***
${BASE_URL}     https://api.restful-api.dev/objects
${first_name}   My name
${second_name}  My new name
${third_name}   Another new name


*** Test Cases ***
Get all data
	${response}     GET    ${BASE_URL}  expected_status=200

Post a new object
	${headers}      Create Dictionary    Content-Type=application/json
    Set Suite Variable  ${HEADERS}  ${headers}
	${body}         Create Dictionary    name=${first_name}
	${response}     POST    ${BASE_URL}   headers=${HEADERS}  json=${body}  expected_status=200
	Set Suite Variable  ${ID}  ${response.json()}[id]
	Should Be Equal     ${response.json()}[name]  ${first_name}
	Should Be Equal     ${response.json()}[data]    ${None}

Partially Update an object
	${body}         Create Dictionary    name=${second_name}
	${response}     PATCH    ${BASE_URL}/${ID}  headers=${HEADERS}  json=${body}  expected_status=200
	Should Be Equal     ${response.json()}[name]  ${second_name}
    Should Be Equal     ${response.json()}[data]    ${None}

Update an object
	${data}     Create Dictionary    color=white  size=medium
	${body}         Create Dictionary    name=${third_name}  data=${data}
	${response}     PUT      ${BASE_URL}/${ID}  headers=${HEADERS}  json=${body}  expected_status=200
	Should Be Equal     ${response.json()}[name]  ${third_name}
    Should Be Equal     ${response.json()}[data]    ${data}

Delete an object
	${response}     DELETE   ${BASE_URL}/${ID}  expected_status=200

Try to delete same object
	# This test case is executed only if the previous one passes
	# Should return a status code 404 as item has already been deleted
	Run Keyword If    "${PREV TEST STATUS}" == "PASS"     DELETE   ${BASE_URL}/${ID}  expected_status=404
