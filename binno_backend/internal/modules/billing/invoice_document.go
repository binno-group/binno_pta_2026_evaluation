package billing

import (
	"fmt"
	"strings"
)

// invoiceDocument renders an invoice as a minimal PDF.
func invoiceDocument(invoice Invoice) []byte {
	text := strings.NewReplacer("(", "[", ")", "]", "\\", "/").Replace(
		fmt.Sprintf("Invoice %s  Total: %d UZS tiyin", invoice.Number, invoice.TotalAmount),
	)
	stream := fmt.Sprintf("BT /F1 14 Tf 72 720 Td (%s) Tj ET", text)
	return fmt.Appendf(nil,
		"%%PDF-1.4\n"+
			"1 0 obj<< /Type /Catalog /Pages 2 0 R>>endobj\n"+
			"2 0 obj<< /Type /Pages /Kids[3 0 R] /Count 1>>endobj\n"+
			"3 0 obj<< /Type /Page /Parent 2 0 R /MediaBox[0 0 595 842] "+
			"/Resources<< /Font<< /F1 4 0 R>>>> /Contents 5 0 R>>endobj\n"+
			"4 0 obj<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica>>endobj\n"+
			"5 0 obj<< /Length %d>>stream\n%s\nendstream endobj\n"+
			"trailer<< /Root 1 0 R>>\n%%%%EOF",
		len(stream), stream)
}
