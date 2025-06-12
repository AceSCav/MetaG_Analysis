import pandas as pd

df = pd.read_csv("asv_to_lifestage.tsv", sep='\t')

df["PrimaryLifeStage"] = df["Life_Stages"].apply(lambda x: x.split(';')[0])

color_map = {
    "Polyp": "#FF69B4",     # Hot Pink
    "Ephyra": "#87CEEB",    # Sky Blue
    "Medusae": "#32CD32"    # Lime Green
}

expanded_rows = []
for _, row in df.iterrows():
    asv = row["ASV"]
    life_stages = row["Life_Stages"].split(';')
    for stage in life_stages:
        stage = stage.strip()
        color = color_map.get(stage, "#000000")  # default black if unknown stage
        expanded_rows.append({"#FeatureID": asv, "LifeStage": stage, "Color": color})

expanded_df = pd.DataFrame(expanded_rows)
expanded_df.to_csv("asv-stage-colors.tsv", sep='\t', index=False)