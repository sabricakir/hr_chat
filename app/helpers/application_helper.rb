module ApplicationHelper
  def flash_type_class(type)
    case type
    when :notice
      "bg-green-600"
    when :alert
      "bg-red-600"
    else
      "bg-gray-600"
    end
  end
end
