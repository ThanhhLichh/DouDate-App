import axios from "./axios";


export async function getCouples(page = 1, limit = 10) {
  const res = await axios.get("/admin/couples", {
    params: { page, limit },
  });
  return res.data; // { items, total, page, limit }
}


export async function breakCouple(coupleId) {
  const res = await axios.post(`/admin/couples/${coupleId}/break`);
  return res.data;
}