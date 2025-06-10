import sys
import pandas as pd

with open('/home/aleff/Desktop/MetaG_Analysis/exported-alignment/aligned-dna-sequences.fasta', 'r') as f:
    lines = f.readlines()

df = pd.read_csv('/home/aleff/Desktop/MetaG_Analysis/exported-taxonomy/taxonomy.tsv', sep='\t', header=None)


def taxonomy_setter(sequence, df):
    dicionario_taxon = dict(zip(df.iloc[:, 0], df.iloc[:, 1]))
    
    new_lines = []

    for line in sequence.splitlines():
        print(line)
        if line.startswith('>'):
            identifier = line[1:]
            if identifier in dicionario_taxon:
                new_line = f">{dicionario_taxon[identifier]}"
                new_lines.append(new_line)
            else:
                new_lines.append(line)
        else:
            new_lines.append(line)

    return "\n".join(new_lines)



if __name__ == "__main__":
    fasta_path = sys.argv[1]
    df = pd.read_csv(sys.argv[2], sep='\t', header=None)

    with open(fasta_path) as f:
        sequence = f.read()
    new_content = taxonomy_setter(sequence, df)

    with open(fasta_path.replace(".fasta", "_withTaxonomy.fasta"), 'w') as f:
        f.write(new_content)