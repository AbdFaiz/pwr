import React, { useState } from 'react';
import { Inertia } from '@inertiajs/inertia';
import { Link } from '@inertiajs/inertia-react';

export default function CreatePriceUpdate({ variants, basePriceLevelId }) {
    const [form, setForm] = useState({
        effective_date: new Date().toISOString().split('T')[0],
        ppn_rate: 11,
        price_level_id: basePriceLevelId,
        notes: '',
        prices: variants.map(v => ({
            variant_id: v.id,
            base_price_per_kg: '',
            kg: v.kg,
            name: v.name,
            category: v.category,
            brand: v.brand,
        })),
    });

    const handleChange = (id, field, value) => {
        setForm(prev => ({
            ...prev,
            prices: prev.prices.map(p =>
                p.variant_id === id ? { ...p, [field]: value } : p
            ),
        }));
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        Inertia.post('/price-update', form);
    };

    const formatNumber = (num) => {
        return new Intl.NumberFormat('id-ID').format(num || 0);
    };

    return (
        <div className="p-6">
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold">Update Harga</h1>
                <Link href="/pricelist" className="text-blue-600 hover:underline">
                    ← Kembali ke Pricelist
                </Link>
            </div>

            <form onSubmit={handleSubmit} className="bg-white p-6 rounded shadow">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                    <div>
                        <label className="block text-sm font-medium text-gray-700">Tanggal Berlaku</label>
                        <input
                            type="date"
                            value={form.effective_date}
                            onChange={e => setForm({ ...form, effective_date: e.target.value })}
                            className="w-full border border-gray-300 rounded px-3 py-2 mt-1"
                            required
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700">PPn (%)</label>
                        <input
                            type="number"
                            step="0.01"
                            value={form.ppn_rate}
                            onChange={e => setForm({ ...form, ppn_rate: e.target.value })}
                            className="w-full border border-gray-300 rounded px-3 py-2 mt-1"
                            required
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700">Catatan</label>
                        <input
                            type="text"
                            value={form.notes}
                            onChange={e => setForm({ ...form, notes: e.target.value })}
                            placeholder="Opsional"
                            className="w-full border border-gray-300 rounded px-3 py-2 mt-1"
                        />
                    </div>
                </div>

                <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Produk</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Kategori</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Merek</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">KG</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Harga/kg</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                            {form.prices.map(p => (
                                <tr key={p.variant_id}>
                                    <td className="px-4 py-3 text-sm font-medium">{p.name}</td>
                                    <td className="px-4 py-3 text-sm">{p.category}</td>
                                    <td className="px-4 py-3 text-sm">{p.brand}</td>
                                    <td className="px-4 py-3 text-sm">{p.kg}</td>
                                    <td className="px-4 py-3">
                                        <input
                                            type="number"
                                            value={p.base_price_per_kg}
                                            onChange={e => handleChange(p.variant_id, 'base_price_per_kg', e.target.value)}
                                            className="w-full border border-gray-300 rounded px-3 py-1 text-right"
                                            placeholder="0"
                                        />
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                <div className="mt-6 flex justify-end">
                    <button
                        type="submit"
                        className="bg-green-600 text-white px-6 py-2 rounded hover:bg-green-700"
                    >
                        Simpan Harga
                    </button>
                </div>
            </form>
        </div>
    );
}