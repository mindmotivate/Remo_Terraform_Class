## Dynamo DB Overview

- Fully managed NoSQL database service by AWS.
- Designed for high performance, scalability, and reliability.
- Schema-less, allowing storage and retrieval of any amount of data without a fixed data structure.
- Supports any level of request traffic.
- Offers automatic scaling to handle fluctuating workloads.
- Built-in security features to protect data at rest and in transit.
- Provides low-latency access to data.
- Popular choice for modern web and mobile applications due to its flexibility and ease of use.


### Foundation of NoSQL Databases
NoSQL databases like DynamoDB organize data using a key-value pair model. Each data item is stored as a combination of a unique key and its corresponding value. This simple structure allows for fast and efficient data retrieval, making it suitable for a wide range of applications.

![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/e1a30080-eea8-470c-8eac-51b5253b365b)

**Simple example of Key-Value table with car makers**

| Manufacturer | Model          |
|--------------|----------------|
| Toyota       | Camry          |
| Toyota       | Corolla        |
| Honda        | Civic          |
| Honda        | Accord         |
| Ford         | Mustang        |
| Ford         | Fusion         |

**Exanded table with Year and VIN columns**

| Manufacturer | Model          | Year | VIN              |
|--------------|----------------|------|------------------|
| Toyota       | Camry          | 2022 | 1HGCM66503A007133 |
| Toyota       | Corolla        | 2021 | 2T1BR32E22C004251 |
| Honda        | Civic          | 2023 | JHMFA362X3S003259 |
| Honda        | Accord         | 2020 | 1HGCM82633A004820 |
| Ford         | Mustang        | 2022 | 1FA6P8TH6K5102511 |
| Ford         | Fusion         | 2021 | 3FA6P0H73JR100759 |

Each entry is called an "item". There are 6 items in our example.  
Each item has multiple "attributes".  
We can represent this data in JSON format also:

```json
[
  {
    "Manufacturer": "Toyota",
    "Model": "Camry",
    "Year": 2022,
    "VIN": "1HGCM66503A007133"
  },
  {
    "Manufacturer": "Toyota",
    "Model": "Corolla",
    "Year": 2021,
    "VIN": "2T1BR32E22C004251"
  },
  {
    "Manufacturer": "Honda",
    "Model": "Civic",
    "Year": 2023,
    "VIN": "JHMFA362X3S003259"
  },
  {
    "Manufacturer": "Honda",
    "Model": "Accord",
    "Year": 2020,
    "VIN": "1HGCM82633A004820"
  },
  {
    "Manufacturer": "Ford",
    "Model": "Mustang",
    "Year": 2022,
    "VIN": "1FA6P8TH6K5102511"
  },
  {
    "Manufacturer": "Ford",
    "Model": "Fusion",
    "Year": 2021,
    "VIN": "3FA6P0H73JR100759"
  }
]

```
### Primary Key
The primary key in a database is a unique identifier for each record or row in a table. It plays a crucial role in organizing and accessing data efficiently. Here's a brief explanation of its importance  
**Note: The only unique identifier in this data is the "VIN" because any item can be uniquely identified with it**

```json
{
  "Manufacturer": "Chevrolet",
  "Model": "",
  "Year": "",
  "VIN": "2G1FK1EJ9B9241062"
}
```


This item is still valid even though it lacks values for the "Model" and "Year" attributes because JSON allows for flexibility in data structure. Not all attributes need to be present in every item within a JSON array. In this case, the absence of "Model" and "Year" values simply means that these attributes are not applicable or not provided for this specific item. As long as the required attributes (in this case, "Manufacturer" and "VIN") are present and correctly formatted, the JSON item remains valid.


In DynamoDB, each item must have a primary key attribute(s) which is mandatory. This primary key uniquely identifies each item in the table and is used to retrieve, update, or delete the item. Without a primary key, DynamoDB cannot store or manage the item effectively.


### AWS Dynamo DB creation in console:
![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/65cacd2a-0976-4e91-9b05-c91bb8cc9518)
After creation:
![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/95514a17-c8d9-4972-97c1-81cd0c731a85)

![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/d7741760-46d9-4453-976f-9b6fb1ded58e)



## Dynamo DB with Terraform


### Define a Terraform module for creating a DynamoDB table

```hcl
resource "aws_dynamodb_table" "cars" {
  name           = "cars"  # Specify the name of the DynamoDB table
  billing_mode   = "PAY_PER_REQUEST"  # Set the billing mode to "PAY_PER_REQUEST"
  hash_key       = "VIN"  # Define the hash key for the table, which is the primary key

  attribute {
    name = "VIN"  # Specify the name of the attribute (column) as "VIN"
    type = "S"    # Specify the data type of the attribute as "S" (String)
  }
}
```

- An attribute block begins with the keyword `attribute` followed by curly braces `{}`.
- Inside the attribute block, you specify the properties of the attribute, such as its name and data type.
- You can have multiple attribute blocks within a resource block, each defining a different attribute of the resource.
- Attribute blocks can be expanded as needed to include additional attributes or properties of the resource.
- In the case of the DynamoDB table example, attribute blocks are used to define the attributes (columns) of the table, allowing you to specify details about each attribute individually.

- **Note: It's important to note that specifying the primary key attribute is mandatory when defining a DynamoDB table, as it uniquely identifies each item in the table.**

### Resitry Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table.html 
Required arguments:

- `attribute` - (Required) Set of nested attribute definitions. Only required for hash_key and range_key attributes. See below.
- `hash_key` - (Required, Forces new resource) Attribute to use as the hash (partition) key. Must also be defined as an attribute. See below.
- `name` - (Required) Unique within a region name of the table.

Optional arguments:

- `billing_mode` - (Optional) Controls how you are charged for read and write throughput and how you manage capacity. The valid values are PROVISIONED and PAY_PER_REQUEST. Defaults to PROVISIONED.
- `deletion_protection_enabled` - (Optional) Enables deletion protection for table. Defaults to false.

Attribute:

- `name` - (Required) Name of the attribute
- `type` - (Required) Attribute type. Valid values are S (string), N (number), B (binary).

### Define a Terraform module for adding an item to a DynamoDB table

resource "aws_dynamodb_table_item" "car_items" {
  table_name = aws_dynamodb_table.cars.name  # Set the name of the table where the item will be stored
  hash_key = aws_dynamodb_table.cars.hash_key  # Define the hash key to identify the item
  item = <<EOF

{
  "VIN": {"S": "1HGBH41JXMN109186"},  # Define the VIN attribute with its value and data type
  "Manufacturer": {"S": "Toyota"},  # Define the Manufacturer attribute with its value and data type
  "Make": {"S": "Corolla"},  # Define the Make attribute with its value and data type
  "Year": {"N": "2004"}  # Define the Year attribute with its value and data type
}

EOF
}

### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table_item

This argument supports the following arguments:

- `hash_key` - (Required) Hash key to use for lookups and identification of the item
- `item` - (Required) JSON representation of a map of attribute name/value pairs, one for each attribute. Only the primary key attributes are required; you can optionally provide other attribute name-value pairs for the item.
- `range_key` - (Optional) Range key to use for lookups and identification of the item. Required if there is range key defined in the table.
- `table_name` - (Required) Name of the table to contain the item.
