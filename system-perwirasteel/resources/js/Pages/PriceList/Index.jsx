import React, { useState } from 'react';
import { Inertia } from '@inertiajs/inertia';
import { Link } from '@inertiajs/inertia-react';

export default function PriceList({ groupedVariants, filters, categories }) {
    const [localFilters, setLocalFilters] = useState({
        category: filters.category || '',
    });

    const handleSearch = (e) => {
        e.preventDefault();
        Inertia.get('/pricelist', localFilters, {
            replace: true,
            preserveState: true,
        });
    };

    const formatPrice = (price) => {
        return new Intl.NumberFormat('id-ID').format(price || 0);
    };

    const getPrice = (prices, type, value) => {
        if (type === 'fixed') {
            return prices.find(p => p.quantity_type === 'fixed' && p.quantity === value);
        }
        if (type === 'percent') {
            return prices.find(p => p.quantity_type === 'percent' && p.percentage === value);
        }
        return null;
    };

    return (
        <div className="p-6 bg-gray-50 min-h-screen">
            {/* Header & Filter */}
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold">Pricelist Master</h1>
                <Link href="/price-update/create" className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                    Update Harga
                </Link>
            </div>

            <form onSubmit={handleSearch} className="bg-white p-4 rounded shadow mb-6 grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
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
                    <button type="submit" className="w-full bg-green-600 text-white py-2 rounded hover:bg-green-700">
                        Cari
                    </button>
                </div>
            </form>

            {/* Loop Semua Kategori */}
            {Object.entries(groupedVariants).map(([category, variants]) => (
                <div key={category} className="mb-12">
                    <h2 className="text-xl font-bold text-gray-800 mb-4 border-b pb-2">{category}</h2>

                    {category === 'Wiremesh' && (
                        <table className="min-w-full divide-y divide-gray-200 mb-6">
                            <thead className="bg-gray-50">
                                <tr>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">Produk</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">KG</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">Harga/kg</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">E</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">E100</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">E1200</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">MKS PLUS</th>
                                </tr>
                            </thead>
                            <tbody className="bg-white divide-y divide-gray-200">
                                {variants.map(variant => {
                                    const priceItem = variant.priceLevelItems[0];
                                    if (!priceItem) return null;
                                    const prices = priceItem.calculatedPrices;
                                    const e = getPrice(prices, 'fixed', 50);
                                    const e100 = getPrice(prices, 'fixed', 100);
                                    const e1200 = getPrice(prices, 'fixed', 1200);
                                    const mks = variant.variantAttributes.find(attr => attr.attribute.name === 'mks_plus')?.value;

                                    return (
                                        <tr key={variant.id} className="hover:bg-gray-50">
                                            <td className="px-4 py-3 text-sm font-medium">{variant.name}</td>
                                            <td className="px-4 py-3 text-sm">{variant.weight_per_unit}</td>
                                            <td className="px-4 py-3 text-sm font-medium">{formatPrice(priceItem.base_price_per_kg)}</td>
                                            <td className="px-4 py-3 text-sm text-green-700">{e ? formatPrice(e.total_price_with_ppn) : '-'}</td>
                                            <td className="px-4 py-3 text-sm text-green-700">{e100 ? formatPrice(e100.total_price_with_ppn) : '-'}</td>
                                            <td className="px-4 py-3 text-sm text-blue-700">{e1200 ? formatPrice(e1200.total_price_with_ppn) : '-'}</td>
                                            <td className="px-4 py-3 text-sm font-bold text-red-700">{mks || '-'}</td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    )}

                    {category === 'WF / HBEAM' && (
                        <div className="overflow-x-auto">
                            <table className="min-w-full divide-y divide-gray-200">
                                <thead className="bg-gray-50">
                                    <tr>
                                        <th rowSpan="2" className="px-4 py-3 text-left text-xs font-bold uppercase">Produk</th>
                                        <th rowSpan="2" className="px-4 py-3 text-left text-xs font-bold uppercase">KG</th>
                                        <th colSpan="11" className="px-4 py-2 text-center bg-blue-50 border-x">SBY/SMG</th>
                                        <th colSpan="10" className="px-4 py-2 text-center bg-red-50 border-x">MKS 12M</th>
                                    </tr>
                                    <tr className="bg-gray-50 text-xs uppercase">
                                        {/* SBY/SMG */}
                                        <th className="px-2 py-2 bg-blue-50 border-l">E</th>
                                        <th>E100</th>
                                        <th>E200</th>
                                        <th>E300</th>
                                        <th>E400</th>
                                        <th>E500</th>
                                        <th>E600</th>
                                        <th>E700</th>
                                        <th>E800</th>
                                        <th>E900</th>
                                        <th className="px-2 py-2 bg-blue-50 border-r">E1000</th>
                                        {/* MKS */}
                                        <th className="px-2 py-2 bg-red-50 border-l">E1100</th>
                                        <th>E1200</th>
                                        <th>E1300</th>
                                        <th>E1400</th>
                                        <th>E1500</th>
                                        <th>E1600</th>
                                        <th>E1700</th>
                                        <th>E1800</th>
                                        <th>E1900</th>
                                        <th className="px-2 py-2 bg-red-50 border-r">E2000</th>
                                    </tr>
                                </thead>
                                <tbody className="bg-white divide-y divide-gray-200">
                                    {variants.map(variant => {
                                        const priceItem = variant.priceLevelItems[0];
                                        if (!priceItem) return null;
                                        const prices = priceItem.calculatedPrices;

                                        return (
                                            <tr key={variant.id} className="hover:bg-gray-50">
                                                <td className="px-4 py-3 text-sm font-medium">{variant.name}</td>
                                                <td className="px-4 py-3 text-sm">{variant.weight_per_unit}</td>
                                                {/* SBY/SMG */}
                                                <td className="px-2 py-2 text-green-700">{getPrice(prices, 'fixed', 50) ? formatPrice(getPrice(prices, 'fixed', 50).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 100) ? formatPrice(getPrice(prices, 'fixed', 100).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 150) ? formatPrice(getPrice(prices, 'fixed', 150).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 200) ? formatPrice(getPrice(prices, 'fixed', 200).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 250) ? formatPrice(getPrice(prices, 'fixed', 250).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 300) ? formatPrice(getPrice(prices, 'fixed', 300).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 350) ? formatPrice(getPrice(prices, 'fixed', 350).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 400) ? formatPrice(getPrice(prices, 'fixed', 400).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 450) ? formatPrice(getPrice(prices, 'fixed', 450).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 500) ? formatPrice(getPrice(prices, 'fixed', 500).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2 text-blue-700 font-medium">{getPrice(prices, 'fixed', 1000) ? formatPrice(getPrice(prices, 'fixed', 1000).total_price_with_ppn) : '-'}</td>
                                                {/* MKS */}
                                                <td className="px-2 py-2 text-red-700 font-bold">{getPrice(prices, 'fixed', 1100) ? formatPrice(getPrice(prices, 'fixed', 1100).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 1200) ? formatPrice(getPrice(prices, 'fixed', 1200).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 1300) ? formatPrice(getPrice(prices, 'fixed', 1300).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 1400) ? formatPrice(getPrice(prices, 'fixed', 1400).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 1500) ? formatPrice(getPrice(prices, 'fixed', 1500).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 1600) ? formatPrice(getPrice(prices, 'fixed', 1600).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 1700) ? formatPrice(getPrice(prices, 'fixed', 1700).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 1800) ? formatPrice(getPrice(prices, 'fixed', 1800).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2">{getPrice(prices, 'fixed', 1900) ? formatPrice(getPrice(prices, 'fixed', 1900).total_price_with_ppn) : '-'}</td>
                                                <td className="px-2 py-2 text-red-700 font-bold">{getPrice(prices, 'fixed', 2000) ? formatPrice(getPrice(prices, 'fixed', 2000).total_price_with_ppn) : '-'}</td>
                                            </tr>
                                        );
                                    })}
                                </tbody>
                            </table>
                        </div>
                    )}

                    {category === 'Sheetpile' && (
                        <table className="min-w-full divide-y divide-gray-200">
                            <thead className="bg-gray-50">
                                <tr>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">Produk</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">Type</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">KG</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">Harga/kg</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">E</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">E100</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">E600</th>
                                </tr>
                            </thead>
                            <tbody className="bg-white divide-y divide-gray-200">
                                {variants.map(variant => {
                                    const priceItem = variant.priceLevelItems[0];
                                    if (!priceItem) return null;
                                    const prices = priceItem.calculatedPrices;
                                    const type = variant.variantAttributes.find(attr => attr.attribute.name === 'type')?.value;

                                    return (
                                        <tr key={variant.id} className="hover:bg-gray-50">
                                            <td className="px-4 py-3 text-sm font-medium">{variant.name}</td>
                                            <td className="px-4 py-3 text-sm">{type}</td>
                                            <td className="px-4 py-3 text-sm">{variant.weight_per_unit}</td>
                                            <td className="px-4 py-3 text-sm font-medium">{formatPrice(priceItem.base_price_per_kg)}</td>
                                            <td className="px-4 py-3 text-sm text-green-700">{getPrice(prices, 'fixed', 50) ? formatPrice(getPrice(prices, 'fixed', 50).total_price_with_ppn) : '-'}</td>
                                            <td className="px-4 py-3 text-sm">{getPrice(prices, 'fixed', 100) ? formatPrice(getPrice(prices, 'fixed', 100).total_price_with_ppn) : '-'}</td>
                                            <td className="px-4 py-3 text-sm text-blue-700">{getPrice(prices, 'fixed', 600) ? formatPrice(getPrice(prices, 'fixed', 600).total_price_with_ppn) : '-'}</td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    )}

                    {/* Default Table untuk kategori lain */}
                    {!['Wiremesh', 'WF / HBEAM', 'Sheetpile'].includes(category) && (
                        <table className="min-w-full divide-y divide-gray-200">
                            <thead className="bg-gray-50">
                                <tr>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">Produk</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">KG</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">Harga/kg</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">E</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">E100</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold uppercase">E1200</th>
                                </tr>
                            </thead>
                            <tbody className="bg-white divide-y divide-gray-200">
                                {variants.map(variant => {
                                    const priceItem = variant.priceLevelItems[0];
                                    if (!priceItem) return null;
                                    const prices = priceItem.calculatedPrices;

                                    return (
                                        <tr key={variant.id} className="hover:bg-gray-50">
                                            <td className="px-4 py-3 text-sm font-medium">{variant.name}</td>
                                            <td className="px-4 py-3 text-sm">{variant.weight_per_unit}</td>
                                            <td className="px-4 py-3 text-sm font-medium">{formatPrice(priceItem.base_price_per_kg)}</td>
                                            <td className="px-4 py-3 text-sm text-green-700">{getPrice(prices, 'fixed', 50) ? formatPrice(getPrice(prices, 'fixed', 50).total_price_with_ppn) : '-'}</td>
                                            <td className="px-4 py-3 text-sm">{getPrice(prices, 'fixed', 100) ? formatPrice(getPrice(prices, 'fixed', 100).total_price_with_ppn) : '-'}</td>
                                            <td className="px-4 py-3 text-sm text-blue-700">{getPrice(prices, 'fixed', 1200) ? formatPrice(getPrice(prices, 'fixed', 1200).total_price_with_ppn) : '-'}</td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    )}
                </div>
            ))}
        </div>
    );
}