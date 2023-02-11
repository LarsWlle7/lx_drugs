# Using OX inventory

- ### Items
    If you're using ox_inventory, you don't have to execute the SQL query to add items.   Instead add the following to your config:
    ```lua
    ["coke"] = {
        label = "Coke",
        description = "Drugs",
        weight = 440, -- Weight in grams
        stack = true,
        close = true,
        consume = 0, -- disables consuming
    },
    ["processed_coke"] = {
        label = "Processed Coke",
        description = "Processed drugs",
        weight = 220, -- Weight in grams
        stack = true,
        close = true,
        consume = 0, -- disables consuming
    },
    ```
    These are just examples. You can change these if you want.
- ### Storage
    To open a lab storage, it requires an inventory. If you want the storage to open in an ox inventory, you can enable this in the config.