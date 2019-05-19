#Requirements 
    #Pester 4.8.1+
    #Azure CLI

#set error action preference to catch Azure CLI errors
$global:erroractionpreference = 1

#all the azure cli commands are outputed into variables
#this is because they would normally write their output and interfere with Pester expectations
#it also makes it easier to grab any details that come back such as the SAS Key 

#this creates the resource group
function createResourceGroup($resourcegroup, $locate){
    #removed if statement, Azure errors now caught if group already exists    
    #$exists = az group exists --name $resourcegroup
    #if ($exists -eq "false") {

        $resource = az group create --location $locate --name $resourcegroup
        Write-Output "Created"

    #}
    #Else{
    #Throw "Resource Group already exists"
    #}
}

#Storage can be created as a blob storage but blob creation requires a container so we make both here
#lowercase only for storename
function createStorageBlob($storename, $resourcegroup, $containername){

        $account = az storage account create --name $storename --resource-group $resourcegroup --kind BlobStorage --access-tier Cool 
        $container = az storage container create --name $containername --account-name $storename --public-access blob 
        Write-Output "Created"
}


#This creates a blob within a specific storage and uploads to it 
#Azure will create a blob if one does not already exist to be uploaded to
#added no progress flag to upload and download as Pester read it as an output
#could add more handling for this
function uploadFileBlob($filepath, $blobname, $containername, $storename){

        $upload = az storage blob upload --file $filepath --container-name $containername --name $blobname --account-name $storename --no-progress
        Write-Output "Uploaded"
}

#this generates an expiry date 30 minutes from start
#then creates a SAS token with it
#then uses that token to download the blob into a file
#requirements to generate a working SAS key not clear in the current CLI reference
#during testing found that a key without an expiry would not work 
#not really an issue as an expiry is good practice regardless
#could possibly use a wget here to download the file as the generate command allows for output as a uri
function downloadWithSAS($containername, $blobname, $storename, $writepath){

        $end = (Get-Date).AddMinutes(30).ToString("yyyy-MM-dTH:mZ")
        $key = az storage blob generate-sas --container-name $containername --name $blobname --account-name $storename --permissions r --expiry $end 
        $download = az storage blob download --container-name $containername --file $writepath --name $blobname --account-name $storename --sas-token $key --no-progress
        Write-Output "Downloaded"
}


#Deletes the resource group 
#Does not prompt for confirmation
function deleteResourceGroup($resourcegroup){

        az group delete --name $resourcegroup --yes 
        Write-Output "Deleted"       
}
#Pester tests

function runTest($upload = 'C:\files\test.txt', $download = 'C:\newfiles\test.txt'){

Describe 'createResourceGroup'{
    It "Creates a new resource group"{
        $group = createResourceGroup TestGroup australiaeast
        $group | Should Be Created
    }
}

Describe 'createStorageBlob'{
    It "Creates a new Storage Blob"{
        $blob = createStorageblob teststore286 TestGroup testcontainer
        $blob | Should Be Created
    }
}

Describe 'uploadFileBlob'{
    It "Uploads a file to blob storage"{
        $file = uploadFileBlob $upload testingblob testcontainer teststore286
        $file | Should Be Uploaded
    }
}

Describe 'downloadWithSAS'{
    It "Generates a SAS key then uses it to download the file"{
        $key = downloadWithSAS testcontainer testingblob teststore286 $download
        $key | Should Be Downloaded
    }
}

Describe 'deleteResourceGroup'{
    It "Deletes a Resource Group"{
        $group = deleteResourceGroup TestGroup
        $group | Should Be "Deleted"
    }
}

}