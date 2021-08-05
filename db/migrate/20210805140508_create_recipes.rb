class CreateRecipes < ActiveRecord::Migration[6.1]
  def change
    create_table :recipes do |t|
      t.jsonb :data
    end
    execute("create extension IF NOT EXISTS pg_trgm")
    execute("CREATE INDEX recipe_title_idx ON recipes USING gin(lower(data->>'title') gin_trgm_ops)")
  end
end
