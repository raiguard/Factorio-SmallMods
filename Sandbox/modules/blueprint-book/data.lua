local book = table.deepcopy(data.raw["blueprint-book"]["blueprint-book"])

book.name = "test-blueprint-book"
book.localised_name = "Blueprint library"

data:extend{book}