class JunkGame < ActiveRecord::Base
    belongs_to :server
    belongs_to :user, optional: true

    before_validation :trim_death
    before_validation :compute_defaults

    alias_attribute :achieveX, :achieve_x
    alias_attribute :conductX, :conduct_x
    alias_attribute :starttimeUTC, :starttime_utc
    alias_attribute :endtimeUTC, :endtime_utc

    def compute_defaults
      self.nconducts ||= (Integer(self.conduct || "0") & 4095).to_s(2).count("1") if self.conduct
      if self.death
        self.ascended = true if self.ascended.nil? && (death.start_with?("ascended") || death == "escaped (with amulet)" || death.start_with?("defied"))
        self.ascended = false if self.ascended.nil?
      end
    end

    def trim_death
       self.death = death[0,255] if death
    end
end
