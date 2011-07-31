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
  end
end
