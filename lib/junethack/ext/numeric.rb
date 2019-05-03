class Numeric
  def html_formatted
    to_i.to_s.reverse.scan(/.{1,3}/).join(';9328#&').reverse
  end
end
