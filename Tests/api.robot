*** Settings ***
Library     RequestsLibrary
Library     Collections
Test Tags   Test  API


*** Variables ***
${BASE_URL}     https://api.restful-api.dev/objects


*** Test Cases ***
Test connection
	${response}     GET    ${BASE_URL}  expected_status=200

Post a new object
	${headers}      Create Dictionary    Content-Type=application/json
	${body}         Create Dictionary    name=My name
	${response}     POST    ${BASE_URL}   headers=${headers}  json=${body}
	Log To Console      ${response.json()}[id]
	Set Suite Variable  ${HEADERS}  ${headers}
	Set Suite Variable  ${ID}  ${response.json()}[id]

Partially Update an object
	${body}         Create Dictionary    name=My new name
	${response}     PATCH    ${BASE_URL}/${ID}  headers=${HEADERS}  json=${body}
	Log To Console    ${response.json()}[id]
    Log To Console    ${response.json()}[name]

Update an object
	${body}         Create Dictionary    name=Another new name
	${response}     PUT      ${BASE_URL}/${ID}  headers=${HEADERS}  json=${body}
	Log To Console    ${response.json()}[id]
    Log To Console    ${response.json()}[name]

Delete an object
	${response}     DELETE   ${BASE_URL}/${ID}
	Log To Console    ${response.json()}[message]
