<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Xuất file — GiaPhả</title>
  <link rel="stylesheet" href="css/style.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
</head>
<body>
  <header class="navbar small">
    <a class="brand" href="index.jsp">GiaPhả<span class="brand-dot">.</span></a>
    <nav class="breadcrumb">
      <a href="index.jsp">Trang chủ</a> / <span>Xuất file</span>
    </nav>
    <div class="nav-actions">
      <a class="btn ghost" href="index.jsp">Quay về</a>
    </div>
  </header>

  <main class="container">
    <section class="panel">
      <div class="panel-head">
        <h2>Xuất dữ liệu</h2>
      </div>

      <div class="card">
        <h4>Chọn phạm vi</h4>
        <label><input type="radio" name="scope" value="all" checked> Toàn bộ gia phả</label><br>
        <label><input type="radio" name="scope" value="branch" disabled> Nhánh hiện tại (chưa hỗ trợ)</label>
      </div>
      
      <div class="card" style="margin-top:12px">
        <h4>Chọn định dạng</h4>
        <div style="display:flex;gap:12px;margin-top:8px">
          <button class="btn large" id="expJson">Xuất JSON</button>
          <button class="btn large" id="expPdf">Xuất PDF</button>
          <button class="btn large" id="expXls">Xuất Excel</button>
        </div>
      </div>
    </section>
  </main>

  <footer class="footer small">
    <div>© 2025 — GiaPhả</div>
  </footer>

  <script>
    async function loadFamily(){
        try {
            const response = await fetch('loadData.jsp?key=gp_family');
            if (!response.ok) throw new Error('Network response was not ok');
            const data = await response.json();
            return data.value || { members: [] };
        } catch (error) {
            console.error('Lỗi tải dữ liệu gia phả:', error);
            return { members: [] };
        }
    }
    
    function download(filename, text) {
      const a = document.createElement('a');
      a.href = URL.createObjectURL(new Blob([text], { type: 'application/octet-stream' }));
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      a.remove();
    }

    document.getElementById('expJson').addEventListener('click', async ()=> {
      const data = await loadFamily();
      const txt = JSON.stringify(data, null, 2);
      download('giapha.json', txt);
      alert('Đã tải JSON.');
    });

    document.getElementById('expPdf').addEventListener('click', async ()=> {
      const { jsPDF } = window.jspdf;
      const doc = new jsPDF();
      const data = await loadFamily();
      
      doc.setFontSize(14);
      doc.text('Gia phả — Export', 14, 18);
      doc.setFontSize(10);
      let y = 30;
      
      data.members.forEach((m, idx)=>{
        doc.text(`${idx+1}. ${m.name} — ${m.year || ''} (ID: ${m.id})`, 14, y);
        y += 8;
        if(y > 270){ doc.addPage(); y = 20; }
      });
      doc.save('giapha.pdf');
    });

    document.getElementById('expXls').addEventListener('click', async ()=> {
      const data = await loadFamily();
      const rows = [['ID','Tên','Năm sinh','Giới tính','ParentID','SpouseID','Ghi chú']];
      data.members.forEach(m=>{
        rows.push([m.id, m.name, m.year || '', m.gender, m.parentId || '', m.spouseId || '', m.relation || '']);
      });

      const ws = XLSX.utils.aoa_to_sheet(rows);
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, "GiaPhả");
      XLSX.writeFile(wb, "giapha.xlsx");
    });
  </script>
</body>
</html>