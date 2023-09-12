*** Settings ***
Library     RequestsLibrary
Library     Collections
Variables   VARIABLES/api_variables.py
Test Tags   Test  API


*** Variables ***
${BASE_URL}         https://api.restful-api.dev/objects
&{headers}          Content-Type=application/json
&{payload_post}     name=${FIRST_NAME}
&{payload_patch}    name=${SECOND_NAME}
&{data}             color=white  size=medium
&{payload_put}      name=${THIRD_NAME}  data=${data}


*** Test Cases ***
Get all data
	[Documentation]  Should return a 200 status code in less than <timeout>
	TRY
        ${response}     GET    ${BASE_URL}  expected_status=200  timeout=2
    EXCEPT  ReadTimeout  type=start
    	${response_exists}  Variable Should Not Exist  ${response}
    	Run Keyword If  ${response_exists} == ${None}  Set Test Message    Le temps imparti est écoulé.
    ELSE
        ${cookies}  Convert To List    ${response.cookies}
        # Log cookies to console only if list is not empty
        Run Keyword If    ${cookies} != @{EMPTY}  Log To Console    ${cookies}
    END

Post a new object
	[Documentation]  Response should return a 200 status code
    ...              Checks that value of "name" has been set accordingly
    ...              and value of "data" is null
    Set Suite Variable  ${HEADERS}  ${headers}
	${response}     POST    ${BASE_URL}   headers=${HEADERS}  json=${payload_post}  expected_status=200
	Set Suite Variable  ${ID}  ${response.json()}[id]
	Should Be Equal     ${response.json()}[name]  ${FIRST_NAME}
	Should Be Equal     ${response.json()}[data]    ${None}

Partially Update an object
	[Documentation]  Response should return a 200 status code
    ...              Checks that value of "name" has been updated accordingly
    ...              and value of "data" is still null
	${response}     PATCH    ${BASE_URL}/${ID}  headers=${HEADERS}  json=${payload_patch}  expected_status=200
	Should Be Equal     ${response.json()}[name]  ${SECOND_NAME}
    Should Be Equal     ${response.json()}[data]    ${None}

Update an object
	[Documentation]  Response should return a 200 status code
	...              Checks that values of "name" and "data" keys have been
	...              updated accordingly
	${response}     PUT      ${BASE_URL}/${ID}  headers=${HEADERS}  json=${payload_put}  expected_status=200
	Should Be Equal     ${response.json()}[name]  ${THIRD_NAME}
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
	[Documentation]  Response should return a 404 status code as object has
	...              already been deleted
	${response}     GET    ${BASE_URL}${ID}  expected_status=404
