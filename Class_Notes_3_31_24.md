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





