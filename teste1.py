import pandas as pd
import sys
from itertools import count
counter = count(1)

def limpar_taxon(taxon):
    if pd.isna(taxon) or not str(taxon).strip() or "Unassigned" in str(taxon):
        return f"Unassigned_{next(counter)}"
    
    partes = str(taxon).split(";")
    partes_limpos = [parte.split("__")[-1].strip().replace(" ", "_").replace("(", "").replace(")", "")
                    for parte in partes if "__" in parte]
    
    if not partes_limpos:
        return f"Unassigned_{next(counter)}"
    
    return f"{'_'.join(partes_limpos)}_{next(counter)}"

def taxonomy_setter(sequence, df):
    if df.shape[1] < 2:
        raise ValueError("DataFrame deve ter pelo menos 2 colunas")
    
    # Verifica duplicatas
    if df.iloc[:, 0].duplicated().any():
        raise ValueError("Existem identificadores duplicados na primeira coluna do DataFrame")
    
    dicionario_taxon = dict(zip(df.iloc[:, 0], df.iloc[:, 1]))
    new_lines = []

    for line in sequence.splitlines():
        if not line.strip():  # Pula linhas vazias
            continue
        if line.startswith('>'):
            identifier = line[1:].split()[0]  # Pega apenas o primeiro campo após >
            if identifier in dicionario_taxon:
                new_lines.append(f">{dicionario_taxon[identifier]}")
            else:
                new_lines.append(line)
        else:
            new_lines.append(line)

    return "\n".join(new_lines)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uso: python script.py <arquivo_fasta> <arquivo_tsv>")
        sys.exit(1)
    
    try:
        fasta_path = sys.argv[1]
        df = pd.read_csv(sys.argv[2], sep='\t', header=None)
        
        # Aplica a limpeza na coluna de taxonomia (assumindo que é a segunda coluna)
        if df.shape[1] >= 2:
            df[1] = df[1].apply(limpar_taxon)
        
        with open(fasta_path) as f:
            sequence = f.read()
        
        new_content = taxonomy_setter(sequence, df)
        
        output_path = fasta_path.replace(".fasta", "_withTaxonomy.fasta") if fasta_path.endswith(".fasta") else fasta_path + "_withTaxonomy.fasta"
        
        with open(output_path, 'w') as f:
            f.write(new_content)
            
    except Exception as e:
        print(f"Erro: {e}")
        sys.exit(1)