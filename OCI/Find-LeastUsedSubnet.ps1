# Define the compartment OCID
$compartmentOCID = "Paste Your compartment OCID here"

# Get the list of subnets in the compartment
$subnets = oci network subnet list --compartment-id $compartmentOCID --all | ConvertFrom-Json

# Initialize variables to track the least used subnet
$leastUsedSubnet = $null
$leastUsedPercentage = 100

# Function to calculate the total number of IPs in a CIDR block
function Get-TotalIPsFromCIDR {
    param ($cidrBlock)

    # Extract the CIDR suffix (the part after /)
    $cidrSuffix = $cidrBlock.Split('/')[1]
    $totalIPs = [math]::Pow(2, 32 - [int]$cidrSuffix)
    return $totalIPs
}

# Loop through each subnet to get IP usage details
foreach ($subnet in $subnets.data) {
    $subnetId = $subnet.id
    $subnetName = $subnet."display-name"
    $cidrBlock = $subnet."cidr-block"

    # Get the IP inventory for the subnet using IPAM (IP Address Management)
    $ipInventory = oci network ipam get-subnet-ip-inventory --subnet-id $subnetId | ConvertFrom-Json

    # Extract the IP addresses from the inventory
    $ipAddresses = $ipInventory.data."ip-inventory-subnet-resource-summary"."ip-address"

    # Count the used IPs
    $usedIPs = $ipAddresses.Count

    # Calculate total IPs from the CIDR block
    $totalIPs = Get-TotalIPsFromCIDR $cidrBlock

    # Calculate available IPs
    $availableIPs = $totalIPs - $usedIPs

    # Calculate the percentage of used IPs
    $usedPercentage = [math]::Round(($usedIPs / $totalIPs) * 100, 2)

    # Display information about the subnet
    Write-Host "Subnet: $subnetName, CIDR: $cidrBlock, Used IPs: $usedIPs, Total IPs: $totalIPs, Available IPs: $availableIPs, Used Percentage: $usedPercentage%"

    # Check if this subnet is the least used
    if ($usedPercentage -lt $leastUsedPercentage) {
        $leastUsedPercentage = $usedPercentage
        $leastUsedSubnet = $subnetName
    }
}

# Output the least used subnet
Write-Host "--------------------------------------------------------"
Write-Host "The least used subnet is: $leastUsedSubnet with $leastUsedPercentage% usage."
