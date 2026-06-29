#!/usr/bin/env python3
# ╔══════════════════════════════════════╗
# ║  Bahasa Pemrograman P — Versi 1.0    ║
# ║  Pencipta: Maverick03-star           ║
# ║  Lisensi: Bebas Pakai & Ubah         ║
# ╚══════════════════════════════════════╝
import sys, os, time, subprocess

def jalankan_kode(isi_program, lingkungan_ubah=None):
    if lingkungan_ubah is None:
        lingkungan_ubah = {}
    daftar_baris = isi_program.replace('\r', '').splitlines()
    posisi = 0
    jumlah_baris = len(daftar_baris)

    # Ambil sekumpulan perintah yang menjorok ke dalam
    def ambil_blok(kedudukan_induk):
        awal = kedudukan_induk + 1
        kedalaman = None
        daftar_isi = []
        while awal < jumlah_baris:
            teks = daftar_baris[awal]
            bersih = teks.rstrip()
            if not bersih:
                awal += 1
                continue
            jumlah_spasi = len(teks) - len(teks.lstrip())
            if kedalaman is None:
                kedalaman = jumlah_spasi
            if jumlah_spasi < kedalaman:
                break
            daftar_isi.append(bersih)
            awal += 1
        return "\n".join(daftar_isi), awal

    # Jalankan satu per satu
    while posisi < jumlah_baris:
        teks_asli = daftar_baris[posisi].rstrip()
        teks = teks_asli.strip()
        posisi += 1
        if not teks or teks.startswith("#"):
            continue

        # ── TAMPILKAN KELUARAN ──
        if teks.startswith("tulis "):
            bagian = teks[6:].split()
            hasil = ""
            for potong in bagian:
                if potong[:1] in "\"'" and potong[-1:] in "\"'":
                    hasil += potong[1:-1] + " "
                elif potong in lingkungan_ubah:
                    hasil += str(lingkungan_ubah[potong]) + " "
                else:
                    try:
                        hasil += str(eval(potong, {}, lingkungan_ubah)) + " "
                    except:
                        hasil += potong + " "
            print(hasil)

        # ── BACA MASUKAN PENGGUNA ──
        elif " -> " in teks and teks.startswith("baca "):
            pesan, nama_var = teks[5:].split(" -> ", 1)
            pesan = pesan.strip().strip("\"'")
            lingkungan_ubah[nama_var.strip()] = input(pesan)

        # ── BUAT UBAHAN/NILAI ──
        elif "=" in teks and not teks.startswith(("jika", "selama", "ulang", "fungsi", "tulis", "baca", "tunggu", "jalankan", "tulis_berkas", "baca_berkas")):
            kiri, kanan = teks.split("=", 1)
            nama = kiri.strip()
            isi = kanan.strip()
            try:
                lingkungan_ubah[nama] = eval(isi, {}, lingkungan_ubah)
            except:
                lingkungan_ubah[nama] = isi

        # ── PERULANGAN HITUNGAN ──
        elif teks.startswith("ulang "):
            nilai = teks.replace("ulang ", "").strip().rstrip(":")
            jumlah = int(nilai)
            blok_isi, posisi = ambil_blok(posisi - 1)
            for nomor in range(1, jumlah + 1):
                lingkungan_ubah["_"] = nomor
                jalankan_kode(blok_isi, lingkungan_ubah.copy())

        # ── PERULANGAN SYARAT ──
        elif teks.startswith("selama "):
            syarat = teks[7:].strip().rstrip(":")
            blok_isi, posisi = ambil_blok(posisi - 1)
            while eval(syarat, {}, lingkungan_ubah):
                jalankan_kode(blok_isi, lingkungan_ubah)

        # ── PERCABANGAN SYARAT ──
        elif teks.startswith("jika "):
            syarat = teks[5:].strip().rstrip(":")
            blok_jika, posisi = ambil_blok(posisi - 1)
            blok_lain = ""
            daftar_atau = []
            while posisi < jumlah_baris:
                b = daftar_baris[posisi].strip()
                if b.startswith("lain:"):
                    blok_lain, posisi = ambil_blok(posisi)
                    break
                elif b.startswith("atau "):
                    syarat_a = b[5:].strip().rstrip(":")
                    isi_a, posisi = ambil_blok(posisi)
                    daftar_atau.append((syarat_a, isi_a))
                else:
                    break
            if eval(syarat, {}, lingkungan_ubah):
                jalankan_kode(blok_jika, lingkungan_ubah)
            else:
                terpenuhi = False
                for sy, isi in daftar_atau:
                    if eval(sy, {}, lingkungan_ubah):
                        jalankan_kode(isi, lingkungan_ubah)
                        terpenuhi = True
                        break
                if not terpenuhi and blok_lain:
                    jalankan_kode(blok_lain, lingkungan_ubah)

        # ── FUNGSI BUATAN SENDIRI ──
        elif teks.startswith("fungsi "):
            sisa = teks[7:]
            nama_fungsi, arg = sisa.split("(", 1)
            nama_fungsi = nama_fungsi.strip()
            daftar_arg = [a.strip() for a in arg.split(")")[0].split(",") if a.strip()]
            badan_fungsi, posisi = ambil_blok(posisi - 1)
            def buat_fungsi(isi=badan_fungsi, daftar_nama=daftar_arg):
                def jalankan_arg(*nilai_masuk):
                    salin_lingkungan = lingkungan_ubah.copy()
                    for urut, nama_arg in enumerate(daftar_nama):
                        salin_lingkungan[nama_arg] = nilai_masuk[urut]
                    jalankan_kode(isi, salin_lingkungan)
                return jalankan_arg
            lingkungan_ubah[nama_fungsi] = buat_fungsi()

        # ── URUS BERKAS ──
        elif teks.startswith("tulis_berkas "):
            nm, isi = teks[13:].split(",", 1)
            nm = nm.strip().strip("\"'")
            isi = isi.strip().strip("\"'")
            with open(nm, "w", encoding="utf-8") as f:
                f.write(isi)
        elif teks.startswith("baca_berkas "):
            nm, sasaran = teks[12:].split(" -> ", 1)
            nm = nm.strip().strip("\"'")
            sasaran = sasaran.strip()
            with open(nm, "r", encoding="utf-8") as f:
                lingkungan_ubah[sasaran] = f.read()

        # ── WAKTU & PERINTAH SISTEM ──
        elif teks.startswith("tunggu "):
            waktu = float(teks[7:])
            time.sleep(waktu)
        elif teks.startswith("jalankan "):
            perintah = teks[9:].strip().strip("\"'")
            keluaran = subprocess.getoutput(perintah)
            print(keluaran)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("⚠️  Pemakaian: p namaprogram.p")
        sys.exit(1)
    lokasi_berkas = sys.argv[1]
    if not os.path.isfile(lokasi_berkas):
        print(f"❌ Berkas '{lokasi_berkas}' tidak ditemukan!")
        sys.exit(1)
    try:
        with open(lokasi_berkas, encoding="utf-8") as f:
            isi = f.read()
        jalankan_kode(isi)
    except Exception as e:
        print(f"💥 Galat: {str(e)}")
        sys.exit(1)
