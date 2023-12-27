*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library           RPA.Browser.Selenium        auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           Collections
Library           RPA.Robocloud.Secrets
Library           OperatingSystem

*** Variables ***
${url}            https://robotsparebinindustries.com/#/robot-order

${IMG_FOLDER}     ${CURDIR}${/}image_files
${PDF_FOLDER}     ${CURDIR}${/}pdf_files
${OUT_FOLDER}  ${CURDIR}${/}output

${ORDER_CSV_FILE}    ${CURDIR}${/}orders.csv
${ZIP_FILE}       ${OUT_FOLDER}${/}pdf_archive.zip
${CSV_WEBSITE}        https://robotsparebinindustries.com/orders.csv


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Folder Management
    Open the robot order website
    

    ${orders}=    Get Orders

    FOR     ${order}     IN     @{orders}
            Close the annoying modal
            Fill the form     ${order}
            Wait Until Keyword Succeeds     10x     2s    Preview the robot
            Wait Until Keyword Succeeds     10x     2s    Submit The Order
            ${orderid}  ${img_filename}=    Take a screenshot of the robot
            ${pdf_filename}=                Store the receipt as a PDF file    ORDER_NUMBER=${order_id}
            Embed the robot screenshot to the receipt PDF file     IMG_FILE=${img_filename}       PDF_FILE=${pdf_filename}       
            Go to order another robot
    END
    
    Create a ZIP file of the receipts

    Log Out And Close The Browser
   

 

*** Keywords ***
Open the robot order website
    [Documentation]    use Selenium to open available browser
    Open Available Browser    ${url}

Folder Management
    [Documentation]    Using Built-in keys to create and empty directory
    Log To console      Making the workspace ready
    Create Directory    ${OUT_FOLDER}
    Create Directory    ${IMG_FOLDER}
    Create Directory    ${PDF_FOLDER}

    Empty Directory     ${IMG_FOLDER}
    Empty Directory     ${PDF_FOLDER}
    Empty Directory     ${OUT_FOLDER}    
   

Get orders
    [Documentation]    Download csv file, read as table using RPA.Tables and return the data

    Download      url=${CSV_WEBSITE}         target_file=${ORDER_CSV_FILE}    overwrite=True
    ${table}=     Read table from CSV     path=${ORDER_CSV_FILE}
    [Return]      ${table}

Close the annoying modal 
    [Documentation]    Close the annoying popup on the top

     Set Local Variable              ${btn_ok}        //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
     Wait And Click Button           ${btn_ok}    

Fill the form
    [Documentation]    Filling the form will be done here.

    [Arguments]     ${myrow}

    Set Local Variable    ${order_no}   ${myrow}[Order number]
    Set Local Variable    ${head}       ${myrow}[Head]
    Set Local Variable    ${body}       ${myrow}[Body]
    Set Local Variable    ${legs}       ${myrow}[Legs]
    Set Local Variable    ${address}    ${myrow}[Address]

    Set Local Variable      ${input_head}       //*[@id="head"]
    Set Local Variable      ${input_body}       body
    Set Local Variable      ${input_legs}       xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    Set Local Variable      ${input_address}    //*[@id="address"]
    Set Local Variable      ${btn_preview}      //*[@id="preview"]
    Set Local Variable      ${btn_order}        //*[@id="order"]
    Set Local Variable      ${img_preview}      //*[@id="robot-preview-image"]


    Select From List By Value       ${input_head}           ${head}

    Select Radio Button             ${input_body}           ${body}

    Input Text                      ${input_legs}           ${legs}
    
    Input Text                      ${input_address}        ${address}

Preview the robot
    [Documentation]    Preview the robot code here.
    Set Local Variable              ${btn_preview}      //*[@id="preview"]
    Set Local Variable              ${img_preview}      //*[@id="robot-preview-image"]
    Click Button                    ${btn_preview}
    Wait Until Element Is Visible   ${img_preview}

Submit the order
    [Documentation]    Submit the order
    Set Local Variable              ${btn_order}        //*[@id="order"]
    Set Local Variable              ${lbl_receipt}      //*[@id="receipt"]
    Click button                    ${btn_order}
    Page Should Contain Element     ${lbl_receipt}

Take a screenshot of the robot
    [Documentation]    Take a screenshot of robot alone
    # local variables for the UI elements
    Set Local Variable      ${lbl_orderid}      xpath://html/body/div/div/div[1]/div/div[1]/div/div/p[1]
    Set Local Variable      ${img_robot}        //*[@id="robot-preview-image"]

    Wait Until Element Is Visible   ${img_robot}
    Wait Until Element Is Visible   ${lbl_orderid} 

    #get the order ID   
    ${orderid}=                     Get Text            //*[@id="receipt"]/p[1]

    # Create the File Name
    Set Local Variable              ${fully_qualified_img_filename}    ${IMG_FOLDER}${/}${orderid}.png

    Sleep   1sec
    Log To Console                  Capturing Screenshot to ${fully_qualified_img_filename}
    Capture Element Screenshot      ${img_robot}    ${fully_qualified_img_filename}
    
    [Return]    ${orderid}  ${fully_qualified_img_filename}

Store the receipt as a PDF file
...  [Arguments]        ${ORDER_NUMBER}
    [Documentation]    Will store the receipt of ordered robot as pdf

     Wait Until Element Is Visible   //*[@id="receipt"]
     Log To Console                  Printing ${ORDER_NUMBER}
     ${order_receipt_html}=          Get Element Attribute   //*[@id="receipt"]  outerHTML

     Set Local Variable              ${fully_qualified_pdf_filename}    ${PDF_FOLDER}${/}${ORDER_NUMBER}.pdf

     Html To Pdf                     content=${order_receipt_html}   output_path=${fully_qualified_pdf_filename}

     [Return]    ${fully_qualified_pdf_filename}

Go to order another robot
    [Documentation]    ordering Another robot
    # Define local variables for the UI elements
    Set Local Variable      ${btn_order_another_robot}      //*[@id="order-another"]
    Click Button            ${btn_order_another_robot}

Log Out And Close The Browser
    [Documentation]    cleanup of browser
    Close Browser

Create a Zip File of the Receipts
    [Documentation]    Creating the zip files
    Archive Folder With ZIP     ${PDF_FOLDER}  ${ZIP_FILE}   recursive=True  include=*.pdf

Embed the robot screenshot to the receipt PDF file
    [Documentation]    Adding image file with pdf
    [Arguments]     ${IMG_FILE}     ${PDF_FILE}

    Log To Console      Printing Embedding image ${IMG_FILE} in pdf file ${PDF_FILE}

    Open PDF        ${PDF_FILE}

    # Create the list of files that is to be added to the PDF
    @{myfiles}=       Create List     ${IMG_FILE}:x=0,y=0

    
    Add Files To PDF    ${myfiles}    ${PDF_FILE}     ${True}    

    




    

    
   

    