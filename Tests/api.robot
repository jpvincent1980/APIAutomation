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
Test connection
	${response}     GET    ${BASE_URL}  expected_status=200

Post a new object
	${headers}      Create Dictionary    Content-Type=application/json
    Set Suite Variable  ${HEADERS}  ${headers}
	${body}         Create Dictionary    name=${first_name}
	${response}     POST    ${BASE_URL}   headers=${HEADERS}  json=${body}
	Set Suite Variable  ${ID}  ${response.json()}[id]
	Should Be Equal     ${response.json()}[name]  ${first_name}
	Should Be Equal     ${response.json()}[data]    ${None}

Partially Update an object
	${body}         Create Dictionary    name=${second_name}
	${response}     PATCH    ${BASE_URL}/${ID}  headers=${HEADERS}  json=${body}
	Should Be Equal     ${response.json()}[name]  ${second_name}
    Should Be Equal     ${response.json()}[data]    ${None}

Update an object
	${body}         Create Dictionary    name=${third_name}
	${response}     PUT      ${BASE_URL}/${ID}  headers=${HEADERS}  json=${body}
	Should Be Equal     ${response.json()}[name]  ${third_name}
    Should Be Equal     ${response.json()}[data]    ${None}

Delete an object
	${response}     DELETE   ${BASE_URL}/${ID}
	Log To Console    ${response.json()}[message]
