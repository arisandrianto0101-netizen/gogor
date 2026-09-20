from server import kali, sapa, tambah, waktu_sekarang


def test_tambah():
    assert tambah(2, 3) == 5


def test_kali():
    assert kali(4, 5) == 20


def test_sapa():
    assert "Budi" in sapa("Budi")


def test_waktu_zona_salah():
    assert "tidak dikenal" in waktu_sekarang("Zona/Ngawur")


def test_waktu_ok():
    assert "UTC" in waktu_sekarang("UTC")
