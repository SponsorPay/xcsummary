#!/bin/bash

cd XCSummary/Templates

#!/bin/bash

Template=$(openssl base64 -in Template.html | tr -d '\n')
ActivityTemplateWithoutImage=$(openssl base64 -in ActivityTemplateWithoutImage.html | tr -d '\n')
ActivityTemplateWithImage=$(openssl base64 -in ActivityTemplateWithImage.html | tr -d '\n')
TestCaseHeader=$(openssl base64 -in TestCaseHeader.html | tr -d '\n')
TestCaseTemplate=$(openssl base64 -in TestCaseTemplate.html | tr -d '\n')
TestCaseTemplateFailed=$(openssl base64 -in TestCaseTemplateFailed.html | tr -d '\n')
SummaryTemplate=$(openssl base64 -in SummaryTemplate.html | tr -d '\n')

sed "s/XCTemplateXC/$Template/g" TemplateHeader.h > temp.h
sed "s/XCActivityTemplateWithoutImageXC/$ActivityTemplateWithoutImage/g" temp.h > temp1.h
sed "s/XCActivityTemplateWithImageXC/$ActivityTemplateWithImage/g" temp1.h > temp2.h
sed "s/XCTestCaseHeaderXC/$TestCaseHeader/g" temp2.h > temp3.h
sed "s/XCTestCaseTemplateXC/$TestCaseTemplate/g" temp3.h > temp4.h
sed "s/XCTestCaseTemplateFailedXC/$TestCaseTemplateFailed/g" temp4.h > temp5.h
sed "s/XCSummaryTemplateXC/$SummaryTemplate/g" temp5.h > TemplateGeneratedHeader.h

rm -rf temp.h
rm -rf temp1.h
rm -rf temp2.h
rm -rf temp3.h
rm -rf temp4.h
rm -rf temp5.h