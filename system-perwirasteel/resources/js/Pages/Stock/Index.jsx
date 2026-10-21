import React, { useState } from 'react';
import { Inertia } from '@inertiajs/inertia';
import { Link } from '@inertiajs/inertia-react';

export default function StockIndex({ variants, categories, filters }) {
    const [localFilters, setLocalFilters] = useState({
        category: filters.category || '',
    });

    const [form, setForm] = useState(
        variants.reduce((acc, v) => ({
            ...acc,
            [v.id]: {
                quantity: v.current_stock || 0,
                unit: v.stock_unit || v.unit,
                location: v.location || 'Gudang A'
            }
        }), {})
    );

    const handleFilter = (e) => {
        e.preventDefault();
        Inertia.get('/stock', localFilters, {
            replace: true,
            preserveState: true,
        });
    };

    const handleChange = (id, field, value) => {
        setForm(prev => ({
            ...prev,
            [id]: { ...prev[id], [field]: value }
        }));
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        const data = {
            stocks: Object.keys(form).map(id => ({
                variant_id: parseInt(id),
                quantity: form[id].quantity,
                unit: form[id].unit,
                location: form[id].location,
            }))
        };
        Inertia.post('/stock/update', data);
    };

    const formatNumber = (num) => {
        return new Intl.NumberFormat('id-ID').format(num || 0);
    };

    return (
        <div className="p-6">
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold">Monitoring Stok</h1>
                <Link href="/pricelist" className="text-blue-600 hover:underline">
                    ← Kembali ke Pricelist
                </Link>
            </div>

            {/* Filter */}
            <form onSubmit={handleFilter} className="bg-white p-4 rounded shadow mb-6">
                <div className="flex gap-4">
                    <div className="flex-1">
                        <label className="block text-sm font-medium text-gray-700 mb-1">Kategori</label>
                        <select
                            value={localFilters.category}
                            onChange={e => setLocalFilters({ ...localFilters, category: e.target.value })}
                            className="w-full border border-gray-300 rounded px-3 py-2"
                        >
                            <option value="">Semua Kategori</option>
                            {categories.map(cat => (
                                <option key={cat} value={cat}>{cat}</option>
                            ))}
                        </select>
                    </div>
                    <div className="flex items-end">
                        <button
                            type="submit"
                            className="w-full bg-green-600 text-white py-2 rounded hover:bg-green-700"
                        >
                            Filter
                        </button>
                    </div>
                </div>
            </form>

            {/* Form Stok */}
            <form onSubmit={handleSubmit} className="bg-white rounded shadow overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                        <tr>
                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Produk</th>
                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Kategori</th>
                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Merek</th>
                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">KG</th>
                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Stok Saat Ini</th>
                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Satuan</th>
                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Lokasi</th>
                        </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                        {variants.map(v => (
                            <tr key={v.id} className="hover:bg-gray-50">
                                <td className="px-4 py-3 text-sm font-medium">{v.name}</td>
                                <td className="px-4 py-3 text-sm">{v.category}</td>
                                <td className="px-4 py-3 text-sm">{v.brand}</td>
                                <td className="px-4 py-3 text-sm">{v.kg}</td>
                                <td className="px-4 py-3">
                                    <input
                                        type="number"
                                        value={form[v.id]?.quantity || 0}
                                        onChange={e => handleChange(v.id, 'quantity', e.target.value)}
                                        className="w-full border border-gray-300 rounded px-3 py-1 text-right"
                                    />
                                </td>
                                <td className="px-4 py-3">
                                    <select
                                        value={form[v.id]?.unit || v.unit}
                                        onChange={e => handleChange(v.id, 'unit', e.target.value)}
                                        className="w-full border border-gray-300 rounded px-3 py-1"
                                    >
                                        <option value="batang">batang</option>
                                        <option value="lembar">lembar</option>
                                        <option value="roll">roll</option>
                                        <option value="kg">kg</option>
                                        <option value="ton">ton</option>
                                        <option value="meter">meter</option>
                                    </select>
                                </td>
                                <td className="px-4 py-3">
                                    <input
                                        type="text"
                                        value={form[v.id]?.location || 'Gudang A'}
                                        onChange={e => handleChange(v.id, 'location', e.target.value)}
                                        className="w-full border border-gray-300 rounded px-3 py-1"
                                    />
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>

                <div className="p-4 bg-gray-50 flex justify-end">
                    <button
                        type="submit"
                        className="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700"
                    >
                        Simpan Stok
                    </button>
                </div>
            </form>
        </div>
    );
}