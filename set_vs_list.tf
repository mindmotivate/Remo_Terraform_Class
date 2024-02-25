
# Lists
# Lists are ordered collections of elements where each element is identified by its position or index.
# In Terraform, lists are mutable, meaning you can add, remove, or modify elements within a list after it's defined.


# This is an example of a 'list' with strings
variable "prefix" {
  description = "List of titles"
  type        = list(string)
  default     = ["Mr", "Mrs", "Miss", "Sir", "Madam"]
}

variable "colors" {
  description = "List of colors"
  type        = list(string)
  default     = ["red", "green", "blue"]
}


# This is an example of a 'list' with numbers

variable "numbers" {
  description = "List of numbers"
  type        = list(number)
  default     = [1, 2, 3, 4, 5]
}


variable "boolean_values" {
  description = "List of boolean values"
  type        = list(bool)
  default     = [true, false]
}

variable "ages" {
  description = "List of ages"
  type        = list(number)
  default     = [25, 30, 35, 40, 45]
}


#Sets
# Sets are collections of unique elements, meaning each element can only appear once within the set.
# In Terraform, sets are immutable, meaning you can't directly add or remove elements from a set once it's defined.
# Unless you use a special function


# This is an example of a 'set"
variable "letter_set" {
  type    = set(string)
  default = ["a", "b", "c"]
}

variable "set1" {
  type    = set(number)
  default = [1, 2, 3, 4, 5]
}

variable "set2" {
  type    = set(number)
  default = [4, 5, 6, 7, 8]
}
