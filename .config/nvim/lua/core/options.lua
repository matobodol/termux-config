-- BASIC
vim.o.numberwidth = 5
vim.opt.backspace = "indent,eol,start"
-- Menampilkan nomor baris
vim.opt.number = true

-- ruang untuk icon disebelah number
vim.opt.signcolumn = "yes"
-- Menampilkan nomor baris relatif
vim.opt.relativenumber = true

-- Jarak antar baris
vim.opt.linespace = 70
-- Ukuran tab 4 spasi
vim.opt.tabstop = 3

-- Panjang indentasi otomatis (n) spasi
vim.opt.shiftwidth = 3

-- Gunakan spasi alih-alih tab
vim.opt.expandtab = false

-- Nonaktifkan pembungkusan baris
vim.opt.wrap = false

-- Sinkronisasi clipboard Neovim dengan sistem
vim.opt.clipboard = "unnamedplus"

-- Pengaturan pencarian
vim.opt.ignorecase = true -- Abaikan huruf besar/kecil
vim.opt.smartcase = true  -- Aktifkan pencarian peka huruf besar jika ada huruf besar
vim.opt.hlsearch = true   -- Sorot hasil pencarian
vim.opt.incsearch = true  -- Tampilkan hasil pencarian secara langsung saat mengetik

-- Mode kursor pada editor
vim.opt.cursorline = true -- Sorot baris tempat kursor berada

-- TAMPILAN
-- Menyembunyikan mode di status bar (karena biasanya digantikan oleh plugin)
vim.opt.showmode = false

-- Menampilkan garis vertikal untuk batas teks (misalnya di 80 karakter)
-- vim.opt.colorcolumn = "80"

-- Sorot pasangan tanda kurung (seperti {}, (), [])
-- vim.opt.showmatch = true

-- Gunakan tema warna 256 untuk terminal
vim.opt.termguicolors = true


-- FILE
-- Menyimpan file backup sebelum perubahan (lokasi bisa diatur)
vim.opt.backup = false
vim.opt.writebackup = false

-- Nonaktifkan swap file
vim.opt.swapfile = false

-- Simpan undo dalam file untuk persistensi
vim.opt.undofile = false
vim.opt.undodir = vim.fn.expand("~/.config/nvim/undo")


-- NAVIGASI
-- Aktifkan mouse untuk navigasi
vim.opt.mouse = "a"

-- Memungkinkan berpindah buffer tanpa menyimpan
-- vim.opt.hidden = true

-- Durasi jeda untuk shortcut (ms)
vim.opt.timeoutlen = 1000
vim.opt.updatetime = 300

-- STATUS DAN TAB
-- Menampilkan status bar di bagian bawah
vim.opt.laststatus = 2 -- Selalu tampilkan status global

-- Tampilkan nama tab di bagian atas
vim.opt.showtabline = 2


-- OPTION
-- Waktu tunggu sebelum keluar dari mode insert
vim.opt.ttimeoutlen = 10

-- Membuka tab baru di sebelah kanan (default di sebelah kiri)
vim.opt.splitright = true

-- Membuka jendela baru di bawah (default di atas)
vim.opt.splitbelow = true
