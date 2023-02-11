function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end

function VectorToObject(vector)
  return {
      x = vector.x,
      y = vector.y,
      z = vector.z,
  }
end