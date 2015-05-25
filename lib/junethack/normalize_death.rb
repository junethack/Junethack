require 'pry'
class Game
  def normalize_death
    # no need to be grammatical correct
    death = self.death.gsub /^killed by an /, "killed by a "

    death = death.gsub /, while .*/, ""

    death = death.gsub /hallucinogen-distorted /, ""

    death = death.gsub /by the invisible /, "by "
    death = death.gsub /by (an|a) invisible /, "by a "
    death = death.gsub /by invisible /, "by "

    death = death.gsub(/ (her|his) /, " eir ")
    death = death.gsub(/ (herself|himself) /, " eirself ")
    death = death.gsub(/ (herself|himself)$/, " eirself")

    death = death.gsub(/ (called|named) .*/, "")

    death = death.gsub(/ \(with the Amulet\)$/, "")
    # no lookbehind in 1.8.7
    death = death.gsub(/choked on .*/, "choked on something")

    gold_pieces_regexp = /killed by kicking (-)?([0-9]+) gold pieces?/
    if death =~ gold_pieces_regexp
      if $1.nil? && $2 != "0"
        death = death.gsub(gold_pieces_regexp, "killed by kicking gold pieces")
      elsif $1 == "-"
        death = death.gsub(gold_pieces_regexp, "killed by kicking a negative amount of gold pieces")
      end
    elsif death == "killed by kicking a gold piece"
      # do nothing
    else
      death = death.gsub(/killed by kicking .*/, "killed by kicking something")
    end

    # killed by a falling {foo} -> killed by a falling object (except for rock from a rock trap).
    death = death.gsub(/killed by a falling (?!rock).+$/, "killed by a falling object")

    # consolidate shopkeepers
    death = death.gsub(/M[rs]\. [A-Z].*, the shopkeeper/, "a shopkeeper")

    # consolidate ghosts
    death = death.gsub(/ ghost of .+/, " ghost")

    # poisoned by a rotted {monster} corpse -> poisoned by a rotted corpse
    death = death.gsub(/poisoned by a rotted .* corpse/, "poisoned by a rotted corpse")

    # wrath of deities
    death = death.gsub(/wrath of .+/, "wrath of a deity")

    # consolidate priest & priestess gender; strip the deity.
    death = death.gsub(/priest(ess)?/, "priest(ess)")
    death = death.gsub(/priest\(ess\) of .+/, "priest(ess) of a deity")

    # killed by the {minion} of {deity} -> 'killed by the minion of a deity'.
    # minion list is from vanilla...
    death = death.gsub(/\w+ elemental|Aleax|couatl|Angel|\w+ demon|\w+ devil|(suc|in)cubus|balrog|pit fiend|nalfeshnee|hezrou|vrock|marilith|erinyes) of .+/, "minion of a deity")

    death
  end
end
