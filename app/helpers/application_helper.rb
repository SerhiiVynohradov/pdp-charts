module ApplicationHelper
  def effort_full_label(code)
    case code.to_s
    when "5"
      "5 - Very Hard (10+ full-time days)"
    when "4"
      "4 - Hard (5-10 full-time days)"
    when "3"
      "3 - Medium (3-5 full-time days)"
    when "2"
      "2 - Easy (2-3 full-time days)"
    when "1"
      "1 - Very Easy (<1 full-time day)"
    else
      "-"
    end
  end
end
