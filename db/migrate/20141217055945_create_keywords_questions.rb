class CreateKeywordsQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :keywords_questions, id: false do |t|
      t.belongs_to :keyword
      t.belongs_to :question
    end

    add_index :keywords_questions, [:keyword_id, :question_id], unique: true
  end
end
