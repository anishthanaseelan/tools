import fitz  # PyMuPDF
import io
from PIL import Image

def extract_images_from_pdf(pdf_path, output_folder):
    # Open the PDF
    pdf_file = fitz.open(pdf_path)
    
    # Ensure output directory exists
    import os
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    for page_index in range(len(pdf_file)):
        page = pdf_file[page_index]
        image_list = page.get_images(full=True)

        if not image_list:
            print(f"No images found on page {page_index + 1}")
            continue

        for img_index, img in enumerate(image_list):
            xref = img[0]
            base_image = pdf_file.extract_image(xref)
            image_bytes = base_image["image"]
            image_ext = base_image["ext"]
            
            # Construct filename
            filename = f"image_p{page_index + 1}_{img_index}.{image_ext}"
            filepath = os.path.join(output_folder, filename)

            # Save the image
            with open(filepath, "wb") as f:
                f.write(image_bytes)
                
            print(f"Saved: {filename}")

    pdf_file.close()

# Usage
extract_images_from_pdf("_MG_6427 2.pdf", "extracted_images")