class Refuge < ApplicationRecord

  validates :name, presence: true

  belongs_to :country
  has_many :questionnaires
  has_many :refuge_entities
  has_many :entities, through: :refuge_entities
  has_many :refuge_questions
  has_many :questions, through: :refuge_questions

  enum status: [:good, :regular, :bad]

  def self.search_with query
    if query.present?
      joins(:country).where("refuges.name||refuges.city||refuges.address||countries.name ILIKE ?", "%#{query}%")
    else
      all
    end
  end

  def last_questionnaire
    self.questionnaires.empty? ? nil : self.questionnaires.order(:created_at).last
  end

  def observation_responses
    self.last_questionnaire.nil? ? nil : self.last_questionnaire.responses.joins(:question).where('questions.question_type = 2 AND questions.text != ?', '¿Por qué?')
  end

end
