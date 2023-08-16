mkdir lambda_package
cp -r venv/lib/python/site-packages/* lambda_package
cp -r src lambda_package
cd lambda_package
zip -r ../lambda.zip *
