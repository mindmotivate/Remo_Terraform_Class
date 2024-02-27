### Lists Explained

When you think of a list, think of a collection of items. These items must be in a certain order, but instead of starting with number 1, you start with 0.

This list order can change; it's not set in stone. You can add, remove, or modify the elements in a list. Terraform uses lists to store items of the same "type".

- **Ordered Collection:** Lists maintain the order of elements, meaning the elements are stored in a specific sequence and can be accessed by their index.

- **Mutable:** Lists are mutable, which means you can add, remove, or modify elements within a list after it's defined.

- **Element Types:** In Terraform, lists can contain elements of the same type or elements of different types depending on how the list is defined.

#### Analogy: Shipping List

Imagine you're preparing a shipping list for a warehouse. Your list starts with item number `(0)`, just like in programming, and increments from there.

- **Shipping List (Initial Order):**
  - (0) Apples
  - (1) Bananas
  - (2) Oranges
  - (3) Grapes

Now, let's say you receive a new shipment of mangoes, and you need to add them to your list:

- **Updated Shipping List (After Addition):**
  - (0) Apples
  - (1) Bananas
  - (2) Oranges
  - (3) Grapes
  - (4) Mangoes

Notice how the list starts with item number `(0)`. That's the flexibility of lists! You can also remove or change items as needed, just like modifying a list in Terraform.
