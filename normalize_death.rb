class Game
  def normalize_death
    # no need to be grammatical correct
    death = self.death.gsub /^killey by an /, "killed by a "

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

    death = death.gsub(/killed by kicking .*/, "killed by kicking something")
  end
end
