from Bio import Phylo

asv_to_taxon = {}
with open("taxonomy.tsv") as f:
    next(f)
    for line in f:
        parts = line.strip().split('\t')
        asv_id = parts[0]
        taxon = parts[1].split(';')[-1].strip()  # optional: only keep genus/species
        asv_to_taxon[asv_id] = taxon

tree = Phylo.read("tree.nwk", "newick")
for tip in tree.get_terminals():
    if tip.name in asv_to_taxon:
        tip.name = asv_to_taxon[tip.name]

Phylo.write(tree, "tree_with_taxonomy.nwk", "newick")