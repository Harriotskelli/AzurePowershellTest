# AzurePowershellTest

This is a script to achive these goals in Microsoft Azure using Powershell

   - Creates a Resource Group.

   - Creates a Storage account, with a Blob Storage

   - Uploads ‘some file’ into that blob storage.

   - Creates a SAS key to be allowed to access the blob.

   - Downloads the file from Blob, using the above SAS key.

   - Deletes the Resource Group
   
   - Tests these functions in a Unit Test suite.
  
  #Requirements#
  
  Azure CLI
  
  Pester version 4.8.1 or later (For the testrun)
  
  #start up#
  
  Run the script in powershell then you will be able to run all the listed commands as needed.
  
  If you are not running in the Cloud Shell then you will need to run the az login command first
  
  In the Cloud Shell you can run commands as . ./AzureInterface.ps1; command [parameters]
   
  #Functions#
  
  - runTest [input file (Default=C:\files\test.txt)] [output file (Default=C:\newfiles\test.txt)]
  Will run the test suite
  
  - createResourceGroup [resource group name] [location (Default=australiaeast)]
  Will create a new resource group in the location specified within your Azure subsription
  
  - createStorageBlob [Storage name (Must be in lowercase)] [resource group name] [container name]
  Will create a new Blob Storage account under the resource group defined
  And a Container for Blobs under that storage account
  
  - uploadFileBlob [input file] [blob name] [container name] [storage name]
  Will upload a file to the named container as a blob and give it your blob name
  
  - downloadWithSAS [container name] [blob name] [storage name] [output file]
  Will download a blob as a file using a read only SAS token that will expire after 30 minutes
  
  - deleteResourceGroup [resource group name]
  Will delete the resource group and all contents with no prompt for confirmation
