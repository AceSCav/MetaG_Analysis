from Bio import Phylo

asv_to_taxon = {}
with open("taxonomy.tsv") as f:
    next(f)  
    for line in f:
        parts = line.strip().split('\t')
        asv_id = parts[0]
        taxon_full = parts[1]
        
        tax_levels = taxon_full.split(';')
        # You can choose any level you want below:
        genus = tax_levels[-2].strip() if len(tax_levels) >= 2 else ''
        species = tax_levels[-1].strip() if len(tax_levels) >= 1 else ''
        
        # Final name: you can use species only, genus + species, or full
        taxon_name = f"{genus}_{species}".replace(" ", "_").replace("__", "")
        
        asv_to_taxon[asv_id] = taxon_name or asv_id  # Fallback to ASV ID

# 2. Load the tree and replace tip labels
tree = Phylo.read("tree.nwk", "newick")

for tip in tree.get_terminals():
    if tip.name in asv_to_taxon:
        tip.name = asv_to_taxon[tip.name]

Phylo.write(tree, "tree_with_taxonomy.nwk", "newick")