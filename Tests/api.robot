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
	[Documentation]  Should return a 200 status code in less than <timeout>
	TRY
        ${response}     GET    ${BASE_URL}  expected_status=200  timeout=0.02
    EXCEPT  ReadTimeout  type=start
    	${response_exists}  Variable Should Not Exist  ${response}
    	Run Keyword If  ${response_exists} == ${None}  Set Test Message    Le temps imparti est écoulé.
    ELSE
        ${cookies}  Convert To List    ${response.cookies}
        Log To Console    ${cookies}
    END

Post a new object
	[Documentation]  Response should return a 200 status code
    ...              Checks that value of "name" has been set accordingly
    ...              and value of "data" is null
	${headers}      Create Dictionary    Content-Type=application/json
    Set Suite Variable  ${HEADERS}  ${headers}
	${body}         Create Dictionary    name=${first_name}
	${response}     POST    ${BASE_URL}   headers=${HEADERS}  json=${body}  expected_status=200
	Set Suite Variable  ${ID}  ${response.json()}[id]
	Should Be Equal     ${response.json()}[name]  ${first_name}
	Should Be Equal     ${response.json()}[data]    ${None}

Partially Update an object
	[Documentation]  Response should return a 200 status code
    ...              Checks that value of "name" has been updated accordingly
    ...              and value of "data" is still null
	${body}         Create Dictionary    name=${second_name}
	${response}     PATCH    ${BASE_URL}/${ID}  headers=${HEADERS}  json=${body}  expected_status=200
	Should Be Equal     ${response.json()}[name]  ${second_name}
    Should Be Equal     ${response.json()}[data]    ${None}

Update an object
	[Documentation]  Response should return a 200 status code
	...              Checks that values of "name" and "data" keys have been
	...              updated accordingly
	${data}     Create Dictionary    color=white  size=medium
	${body}         Create Dictionary    name=${third_name}  data=${data}
	${response}     PUT      ${BASE_URL}/${ID}  headers=${HEADERS}  json=${body}  expected_status=200
	Should Be Equal     ${response.json()}[name]  ${third_name}
    Should Be Equal     ${response.json()}[data]    ${data}

Delete an object
	[Documentation]  Response should return a 200 status code
	${response}     DELETE   ${BASE_URL}/${ID}  expected_status=200

Try to delete same object
	[Documentation]  This test case is executed only if the previous one passes
	...              Response should return a status code 404 as item has
	...              already been deleted
	Run Keyword If    "${PREV TEST STATUS}" == "PASS"     DELETE   ${BASE_URL}/${ID}  expected_status=404

Get deleted object
	[Documentation]  Response should return a 404 status code as object has been
	...              deleted
	${response}     GET    ${BASE_URL}${ID}  expected_status=404
